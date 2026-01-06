import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/transaction_controller.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(TransactionController());
    Get.put(NotificationService());
  }
}
