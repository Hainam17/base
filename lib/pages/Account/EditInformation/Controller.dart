import 'package:vhv_basic/import.dart';

class AccountEditInformationController extends GetBaseController {
  AccountEditInformationController()
      : super(
          submitService: 'Member.Profile.edit',
          extraParams: {'id': account['accountId'], 'type': 'Account'},
          rules: {
            'fullName': {
              'required': 'Bạn chưa nhập họ tên'.lang(),
              'maxLength': [100, 'Họ tên không được quá 100 ký tự']
            },
            'email': {
              'required': 'Email không được để trống'.lang(),
              'email': 'Email không đúng định dạng'.lang()
            },
            'phone': {'phoneVN': 'Số điện thoại không đúng định dạng'.lang()},
            'gender': {
              'required': 'Bạn chưa chọn giới tính'.lang(),
            },
            'birthDate': {
              'required': 'Bạn chưa chọn ngày sinh'.lang(),
            }
          },
          useParams: true
        );
  @override
  onInit(){
    params = !empty(account.getData()) ? account.getData() : {};
    super.onInit();
  }

  @override
  onSuccess(response) async {
    await account.assign(params!..addAll(fields), true);
    await super.onSuccess(response);
  }
}
