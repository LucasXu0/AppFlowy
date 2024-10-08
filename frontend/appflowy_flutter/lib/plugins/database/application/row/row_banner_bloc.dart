import 'package:flutter/foundation.dart';

import 'package:appflowy/plugins/database/application/field/field_controller.dart';
import 'package:appflowy/plugins/database/application/row/row_service.dart';
import 'package:appflowy/plugins/database/domain/field_service.dart';
import 'package:appflowy_backend/dispatch/dispatch.dart';
import 'package:appflowy_backend/log.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-user/user_profile.pb.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/row_meta_listener.dart';

part 'row_banner_bloc.freezed.dart';

class RowBannerBloc extends Bloc<RowBannerEvent, RowBannerState> {
  RowBannerBloc({
    required this.viewId,
    required this.fieldController,
    required RowMetaPB rowMeta,
  })  : _rowBackendSvc = RowBackendService(viewId: viewId),
        _metaListener = RowMetaListener(rowMeta.id),
        super(RowBannerState.initial(rowMeta)) {
    _dispatch();
  }

  final String viewId;
  final FieldController fieldController;
  final RowBackendService _rowBackendSvc;
  final RowMetaListener _metaListener;

  UserProfilePB? _userProfile;
  UserProfilePB? get userProfile => _userProfile;

  bool get hasCover => state.rowMeta.cover.data.isNotEmpty;

  @override
  Future<void> close() async {
    await _metaListener.stop();
    return super.close();
  }

  void _dispatch() {
    on<RowBannerEvent>(
      (event, emit) {
        event.when(
          initial: () async {
            await _loadPrimaryField();
            _listenRowMetaChanged();
            final result = await UserEventGetUserProfile().send();
            result.fold(
              (userProfile) => _userProfile = userProfile,
              (error) => Log.error(error),
            );
          },
          didReceiveRowMeta: (RowMetaPB rowMeta) {
            emit(state.copyWith(rowMeta: rowMeta));
          },
          setCover: (RowCoverPB cover) => _updateMeta(cover: cover),
          setIcon: (String iconURL) => _updateMeta(iconURL: iconURL),
          removeCover: () => _removeCover(),
          didReceiveFieldUpdate: (updatedField) {
            emit(
              state.copyWith(
                primaryField: updatedField,
                loadingState: const LoadingState.finish(),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadPrimaryField() async {
    final fieldOrError =
        await FieldBackendService.getPrimaryField(viewId: viewId);
    fieldOrError.fold(
      (primaryField) {
        if (!isClosed) {
          fieldController.addSingleFieldListener(
            primaryField.id,
            onFieldChanged: (updatedField) {
              if (!isClosed) {
                add(RowBannerEvent.didReceiveFieldUpdate(updatedField.field));
              }
            },
          );
          add(RowBannerEvent.didReceiveFieldUpdate(primaryField));
        }
      },
      (r) => Log.error(r),
    );
  }

  /// Listen the changes of the row meta and then update the banner
  void _listenRowMetaChanged() {
    _metaListener.start(
      callback: (rowMeta) {
        if (!isClosed) {
          add(RowBannerEvent.didReceiveRowMeta(rowMeta));
        }
      },
    );
  }

  /// Update the meta of the row and the view
  Future<void> _updateMeta({String? iconURL, RowCoverPB? cover}) async {
    final result = await _rowBackendSvc.updateMeta(
      iconURL: iconURL,
      cover: cover,
      rowId: state.rowMeta.id,
    );
    result.fold((l) => null, (err) => Log.error(err));
  }

  Future<void> _removeCover() async {
    final result = await _rowBackendSvc.removeCover(state.rowMeta.id);
    result.fold((l) => null, (err) => Log.error(err));
  }
}

@freezed
class RowBannerEvent with _$RowBannerEvent {
  const factory RowBannerEvent.initial() = _Initial;
  const factory RowBannerEvent.didReceiveRowMeta(RowMetaPB rowMeta) =
      _DidReceiveRowMeta;
  const factory RowBannerEvent.didReceiveFieldUpdate(FieldPB field) =
      _DidReceiveFieldUpdate;
  const factory RowBannerEvent.setIcon(String iconURL) = _SetIcon;
  const factory RowBannerEvent.setCover(RowCoverPB cover) = _SetCover;
  const factory RowBannerEvent.removeCover() = _RemoveCover;
}

@freezed
class RowBannerState extends Equatable with _$RowBannerState {
  const RowBannerState._();

  const factory RowBannerState({
    required FieldPB? primaryField,
    required RowMetaPB rowMeta,
    required LoadingState loadingState,
  }) = _RowBannerState;

  factory RowBannerState.initial(RowMetaPB rowMetaPB) => RowBannerState(
        primaryField: null,
        rowMeta: rowMetaPB,
        loadingState: const LoadingState.loading(),
      );

  @override
  List<Object?> get props => [
        rowMeta.cover.data,
        rowMeta.icon,
        primaryField,
        loadingState,
      ];
}

@freezed
class LoadingState with _$LoadingState {
  const factory LoadingState.loading() = _Loading;
  const factory LoadingState.finish() = _Finish;
}
