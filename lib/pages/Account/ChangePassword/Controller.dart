import 'package:vhv_basic/import.dart';

class ChangePasswordController extends GetBaseController {
  final bool hasOldPassword;
  final String? submitService;
  final Map? param;
  bool passwordVisibleOld = true;
  bool passwordVisibleNew = true;
  bool passwordVisibleConfluent = true;

  ChangePasswordController({this.hasOldPassword = false, this.submitService,this.param})
      : super(
    submitService: submitService ?? 'Member.User.changePassword',
    useFields: false,
    controllerNames: ['oldPassword', 'password', 'confirmPassword'],
    rules: {
      if (hasOldPassword)
        'oldPassword': {
          'required': 'Bạn chưa nhập mật khẩu cũ.',
        },
      'password': {
        'required': 'Bạn chưa nhập mật khẩu mới.',
        'password': true,
        'invalidPassword': ['123456aA@','12345678aA@','Demo@123'],
      },
      'confirmPassword': {
        'required': 'Bạn chưa nhập lại mật khẩu mới.',
        'equalTo': [
          'password',
          'Nhập lại mật khẩu không khớp với mật khẩu đã nhập'
        ]
      },
    },
  );

  @override
  onSuccess(response) {
    _success();
    super.onSuccess(response);
  }

  _success()async{
    if(!empty(param)){
      showMessage('Đổi mật khẩu thành công', type:'SUCCESS');
      appNavigator.pop();
    }else{
      await Setting('Config').put('hasChangePassword', '1');
      showMessage('Đổi mật khẩu thành công', type:'SUCCESS');
      appNavigator.pop();
      logout();
    }

  }
  @override
  onErrorValidation() {
    update();
    return super.onErrorValidation();
  }

  @override
  submit(){
    if(!empty(param)){
      if(!empty(param!['groupId'])) fields['groupId'] = param!['groupId'];
      if(!empty(param!['id']))fields['id'] = param!['id'];
      if(!empty(param!['classroomId']))fields['classroomId'] = param!['classroomId'];
      }
      update();
      super.submit();
    }

  @override
  onFail(response) {

    if (response != null) {
      if (response is String) response = {'status': response};
      if (response['status'] != null) {
        switch (response['status']) {
          case 'INVALID_OLD_PASSWORD':
            response['message'] =
                response['message'] ?? 'Bạn vui lòng kiểm tra lại thông tin!';
            returnMessageError('oldPassword', 'Mật khẩu cũ không đúng.');
            update();
            break;
          case 'DUPLICATE_OLD_PASSWORD':
            response['message'] = response['message'] ??
                'Bạn vui lòng kiểm tra lại thông tin';
            returnMessageError('password',  'Mật khẩu mới không được trùng với mật khẩu cũ.');
            update();
            break;
          case 'INVALID_PASSWORD':
            response['message'] = response['message'] ??
                'Mật khẩu mới phải có ít nhất 8 ký tự bao gồm chữ số, chữ hoa, chữ thường và ký tự đặc biệt.';
            break;
          case 'PASSWORD_DEFAULT':
            response['message'] = response['message'] ??
                'Mật khẩu bạn nhập là mật khẩu mặc định. Xin vui lòng nhập mật khẩu khác!';
            returnMessageError('password', 'Mật khẩu bạn nhập là mật khẩu mặc định. Xin vui lòng nhập mật khẩu khác!');
            break;
          case 'SUCCESS':
            response['message'] =
                response['message'] ?? 'Đổi mật khẩu thành công';
            break;
          default:
            response['message'] = response['message'] ?? 'Có lỗi xảy ra!';
            break;
        }
        response['status'] = 'FAIL';
      }
    } else {
      response = {'status': 'FAIL', 'message': 'Có lỗi xảy ra!'};
    }
    showMessage(response['message'].toString().lang(),type: response['status']);
    return super.onFail(response);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
