import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/user/application/sign_in_bloc.dart';
import 'package:appflowy/workspace/presentation/home/toast.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:string_validator/string_validator.dart';

class SignInWithMagicLinkButtons extends StatefulWidget {
  const SignInWithMagicLinkButtons({
    super.key,
  });

  @override
  State<SignInWithMagicLinkButtons> createState() =>
      _SignInWithMagicLinkButtonsState();
}

class _SignInWithMagicLinkButtonsState
    extends State<SignInWithMagicLinkButtons> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48.0,
          child: FlowyTextField(
            controller: controller,
            hintText: LocaleKeys.signIn_pleaseInputYourEmail.tr(),
          ),
        ),
        const VSpace(12),
        _ConfirmButton(
          onTap: () {
            if (isEmail(controller.text)) {
              context
                  .read<SignInBloc>()
                  .add(SignInEvent.signedWithMagicLink(controller.text));
              showSnackBarMessage(
                context,
                LocaleKeys.signIn_magicLinkSent.tr(),
                duration: const Duration(seconds: 8),
              );
            }
          },
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (PlatformExtension.isMobile) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: onTap,
        child: FlowyText(
          LocaleKeys.signIn_logInWithMagicLink.tr(),
          fontSize: 14,
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        child: FlowyButton(
          isSelected: true,
          onTap: onTap,
          text: FlowyText.medium(
            LocaleKeys.signIn_logInWithMagicLink.tr(),
            textAlign: TextAlign.center,
          ),
          radius: Corners.s6Border,
        ),
      );
    }
  }
}