import 'package:app_flowy/user/presentation/folder/folder_widget.dart';
import 'package:flowy_infra_ui/style_widget/text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'util/util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('customize the folder path', () {
    const location = 'appflowy';

    setUp(() async {
      await TestFolder.cleanTestLocation(location);
      await TestFolder.setTestLocation(location);
    });

    tearDown(() async {
      await TestFolder.cleanTestLocation(location);
    });

    testWidgets(
        'customize folder name and path when launching app in first time',
        (tester) async {
      const folderName = 'appflowy';
      await TestFolder.cleanTestLocation(folderName);

      await tester.initializeAppFlowy();

      // Click create button
      await tester.tapCreateButton();

      // Set directory
      final cfw = find.byType(CreateFolderWidget);
      expect(cfw, findsOneWidget);
      final state = tester.state(cfw) as CreateFolderWidgetState;
      final dir = await TestFolder.testLocation(null);
      state.directory = dir.path;

      // input folder name
      final ftf = find.byType(FlowyTextField);
      expect(ftf, findsOneWidget);
      await tester.enterText(ftf, 'appflowy');

      // Click create button again
      await tester.tapCreateButton();

      await tester.expectToSeeWelcomePage();

      await TestFolder.cleanTestLocation(folderName);
    });

    testWidgets('open a new folder when launching app in first time',
        (tester) async {
      const folderName = 'appflowy';
      await TestFolder.cleanTestLocation(folderName);
      await TestFolder.setTestLocation(folderName);

      await tester.initializeAppFlowy();

      // set custom folder
      final cfw = find.byType(FolderWidget);
      expect(cfw, findsOneWidget);
      await TestFolder.setTestLocation(folderName);
      (tester.widget(cfw) as FolderWidget).createFolderCallback();

      await tester.wait(1000);
      await tester.expectToSeeWelcomePage();

      await TestFolder.cleanTestLocation(folderName);
    });

    testWidgets('reset to default location', (tester) async {
      await tester.initializeAppFlowy();

      await tester.tapGoButton();

      // home and readme document
      await tester.expectToSeeWelcomePage();

      // open settings and restore the location
      await tester.openSettings();
      await tester.openSettingsPage(SettingsPage.files);
      await tester.restoreLocation();

      expect(await TestFolder.defaultDevelopmentLocation(),
          await TestFolder.currentLocation());
    });
  });
}
