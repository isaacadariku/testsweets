import 'package:stacked/stacked.dart';
import 'package:testsweets/src/app/app.logger.dart';
import 'package:testsweets/src/constants/app_constants.dart';
import 'package:testsweets/src/enums/capture_widget_enum.dart';
import 'package:testsweets/src/enums/widget_type.dart';
import 'package:testsweets/src/extensions/capture_widget_status_enum_extension.dart';
import 'package:testsweets/src/extensions/string_extension.dart';
import 'package:testsweets/src/locator.dart';
import 'package:testsweets/src/models/application_models.dart';
import 'package:testsweets/src/services/testsweets_route_tracker.dart';
import 'package:testsweets/src/services/widget_capture_service.dart';
import 'package:testsweets/utils/error_messages.dart';

import 'widget_capture_view.form.dart';

class WidgetCaptureViewModel extends FormViewModel {
  final log = getLogger('WidgetCaptureViewModel');

  final String projectId;
  final _testSweetsRouteTracker = locator<TestSweetsRouteTracker>();
  final _widgetCaptureService = locator<WidgetCaptureService>();

  WidgetCaptureViewModel({required this.projectId}) {
    syncWithFirestoreWidgetKeys(projectId: projectId);

    _testSweetsRouteTracker.addListener(() {
      _currentView =
          _testSweetsRouteTracker.currentRoute.convertViewNameToValidFormat;
      notifyListeners();
      if (_captureWidgetStatusEnum == CaptureWidgetStatusEnum.inspectMode) {
        notifyListeners();
      }
    });
  }

  String _currentView = '';
  String get currentView => _currentView;

  /// the status enum that express the current state of the view
  CaptureWidgetStatusEnum _captureWidgetStatusEnum =
      CaptureWidgetStatusEnum.idle;
  set captureWidgetStatusEnum(CaptureWidgetStatusEnum captureWidgetStatusEnum) {
    _captureWidgetStatusEnum = captureWidgetStatusEnum;
    notifyListeners();
  }

  CaptureWidgetStatusEnum get captureWidgetStatusEnum =>
      _captureWidgetStatusEnum;

  WidgetDescription? _widgetDescription;
  WidgetDescription? get widgetDescription => _widgetDescription;
  double get descriptionTop =>
      _widgetDescription!.position.y - (WIDGET_DESCRIPTION_VISUAL_SIZE / 2);
  double get descriptionLeft =>
      _widgetDescription!.position.x - (WIDGET_DESCRIPTION_VISUAL_SIZE / 2);

  bool _hasWidgetNameFocus = false;
  bool get hasWidgetNameFocus => _hasWidgetNameFocus;

  String _activeWidgetId = '';
  String get activeWidgetId => _activeWidgetId;

  bool _widgetNameInputPositionIsDown = true;

  bool get widgetNameInputPositionIsDown => _widgetNameInputPositionIsDown;

  String _inputErrorMessage = '';
  String get nameInputErrorMessage => _inputErrorMessage;

  WidgetDescription? _activeWidgetDescription;

  WidgetDescription? get activeWidgetDescription => _activeWidgetDescription;

  List<WidgetDescription> get descriptionsForView =>
      _widgetCaptureService.getDescriptionsForView(
        currentRoute: _testSweetsRouteTracker.currentRoute,
      );

  Future<void> syncWithFirestoreWidgetKeys(
      {required String projectId, bool enableBusy = true}) async {
    if (enableBusy) setBusy(true);
    try {
      await _widgetCaptureService.loadWidgetDescriptionsForProject(
        projectId: projectId,
      );
    } catch (e) {
      log.e('Could not get widgetDescriptions: $e');
    }
    setBusy(false);
  }

  void toggleCaptureView() {
    if (captureWidgetStatusEnum.isAtCaptureMode)
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.idle;
    else
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.captureMode;
  }

  void toggleInspectLayout() {
    if (captureWidgetStatusEnum == CaptureWidgetStatusEnum.inspectMode)
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.idle;
    else
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.inspectMode;
  }

  void updateDescriptionPosition(double x, double y) {
    _widgetDescription = _widgetDescription!.copyWith(
      position: WidgetPosition(
        x: _widgetDescription!.position.x + x,
        y: _widgetDescription!.position.y + y,
      ),
    );
    notifyListeners();
  }

  @override
  void setFormStatus() {
    _widgetDescription =
        _widgetDescription?.copyWith(name: widgetNameValue ?? '');
  }

  Future<void> saveWidgetDescription() async {
    if (_isEmpty()) return;

    setBusy(true);
    _widgetDescription = _widgetDescription?.copyWith(
        viewName:
            _testSweetsRouteTracker.currentRoute.convertViewNameToValidFormat,
        originalViewName: _testSweetsRouteTracker.currentRoute,
        name: widgetNameValue!.convertWidgetNameToValidFormat);

    log.i('descriptionToSave:$_widgetDescription');

    await sendWidgetDescriptionToFirestore();

    setBusy(false);
  }

  bool _isEmpty() {
    if (widgetNameValue!.trim().isEmpty) {
      _inputErrorMessage = ErrorMessages.widgetInputNameIsEmpty;
      notifyListeners();
      return true;
    } else {
      _inputErrorMessage = '';
      return false;
    }
  }

  Future<void> sendWidgetDescriptionToFirestore() async {
    try {
      await _widgetCaptureService.captureWidgetDescription(
        description: _widgetDescription!,
        projectId: projectId,
      );
      captureWidgetStatusEnum =
          CaptureWidgetStatusEnum.captureModeWidgetsContainerShow;
      _widgetDescription = null;
    } catch (e) {
      log.e('Couldn\'t save the widget. $e');
    }
  }

  void setWidgetNameFocused(bool hasFocus) {
    _hasWidgetNameFocus = hasFocus;
    notifyListeners();
  }

  void toggleWidgetsContainer() {
    if (captureWidgetStatusEnum ==
        CaptureWidgetStatusEnum.captureModeWidgetsContainerShow)
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.captureModeAddWidget;
    else
      captureWidgetStatusEnum =
          CaptureWidgetStatusEnum.captureModeWidgetsContainerShow;
  }

  Future<void> addNewWidget(WidgetType widgetType,
      {WidgetPosition? widgetPosition}) async {
    _widgetDescription = WidgetDescription.addAtPosition(
        widgetType: widgetType, widgetPosition: widgetPosition);

    if (!_widgetCaptureService.checkCurrentViewIfAlreadyCaptured(
        _testSweetsRouteTracker.currentRoute))
      _captureViewWhenItsNotAlreadyCaptured();

    _showInputTextField();
  }

  Future<void> _captureViewWhenItsNotAlreadyCaptured() async {
    try {
      _widgetCaptureService.captureWidgetDescription(
          description: WidgetDescription.addView(
              viewName: _testSweetsRouteTracker
                  .currentRoute.convertViewNameToValidFormat,
              originalViewName: _testSweetsRouteTracker.currentRoute),
          projectId: projectId);
      syncWithFirestoreWidgetKeys(projectId: projectId, enableBusy: false);
    } catch (e) {
      log.e("couldn't capture the view : $e");
      //should add a way to notify the user that something wrong happened
      captureWidgetStatusEnum = CaptureWidgetStatusEnum.captureMode;
    }
  }

  void _showInputTextField() {
    toggleWidgetsContainer();
    captureWidgetStatusEnum =
        CaptureWidgetStatusEnum.captureModeWidgetNameInputShow;
  }

  void switchWidgetNameInputPosition() {
    _widgetNameInputPositionIsDown = !widgetNameInputPositionIsDown;
    notifyListeners();
  }

  void closeWidgetNameInput() {
    if (_isEditMode) {
      toggleIsEditMode();
    } else {
      _widgetDescription = null;
      toggleWidgetsContainer();
    }
  }

  void showWidgetDescription(WidgetDescription description) {
    _activeWidgetDescription = description;
    _activeWidgetId = description.id ?? '';
    captureWidgetStatusEnum = CaptureWidgetStatusEnum.inspectModeDialogShow;
  }

  void closeWidgetDescription() {
    _activeWidgetId = '';
    captureWidgetStatusEnum = CaptureWidgetStatusEnum.inspectMode;
  }

  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  void editWidgetDescription() {
    _isEditMode = true;
    _widgetDescription = _activeWidgetDescription;
    _onChangedValue = _activeWidgetDescription?.name ?? '';
    captureWidgetStatusEnum =
        CaptureWidgetStatusEnum.captureModeWidgetNameInputShow;
    notifyListeners();
  }

  void toggleIsEditMode() async {
    _isEditMode = false;
    captureWidgetStatusEnum = CaptureWidgetStatusEnum.inspectMode;

    try {
      await _widgetCaptureService.loadWidgetDescriptionsForProject(
        projectId: projectId,
      );
    } catch (e) {
      log.e('Couldn\'t load the widget descriptions. $e');
    }
    notifyListeners();
  }

  Future<void> deleteWidgetDescription() async {
    if (_onChangedValue.isEmpty) {
      _inputErrorMessage = 'Widget name must not be empty';
      notifyListeners();
    } else {
      _inputErrorMessage = '';
      try {
        setBusy(true);

        log.i('descriptionToDelete:$_widgetDescription');

        await _widgetCaptureService.deleteWidgetDescription(
            projectId: projectId, description: _widgetDescription!);

        setBusy(false);

        toggleIsEditMode();
      } catch (e) {
        setBusy(false);
        log.e('Couldn\'t delete the widget. $e');
      }
    }
  }

  Future<void> updateWidgetDescription() async {
    if (_onChangedValue.isEmpty) {
      _inputErrorMessage = 'Widget name must not be empty';
      notifyListeners();
    } else {
      _inputErrorMessage = '';
      _widgetDescription = _widgetDescription?.copyWith(name: _onChangedValue);

      try {
        setBusy(true);

        log.i('descriptionToUpdate:$_widgetDescription');

        await _widgetCaptureService.updateWidgetDescription(
            projectId: projectId, description: _widgetDescription!);
        setBusy(false);
        toggleIsEditMode();
      } catch (e) {
        setBusy(false);
        log.e('Couldn\'t update the widget. $e');
      }
    }
  }

  String _onChangedValue = '';
  String get onChangedValue => _onChangedValue;

  set onChangedValue(String value) {
    _onChangedValue = value;
    notifyListeners();
  }

  void onChangeWidgetName(String value) {
    onChangedValue = value;
  }
}
