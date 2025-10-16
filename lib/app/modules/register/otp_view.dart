// import 'package:flutter/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:lapangan_kita/app/widgets/basic_app_button.dart';
import 'package:lapangan_kita/app/widgets/input_field.dart';
import 'otp_controller.dart';

class OtpView extends GetView<OTPController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo/logo-app.png',
                        fit: BoxFit.cover,
                        height: 150,
                        width: 150,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Enter Verification Code',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: <TextSpan>[
                              const TextSpan(text: 'We have sent a code to '),
                              TextSpan(
                                text: controller.email.value.isEmpty
                                    ? 'your email'
                                    : controller.email.value,
                                style: const TextStyle(letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Obx(
                        () => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 52,
                                height: 60,
                                child: BorderInputField(
                                  keyType: TextInputType.number,
                                  maxLength: 1,
                                  isLoading: controller.isLoading.value,
                                  hint: '●',
                                  hintSize: 24,
                                  hintWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                  onChanged: (value) {
                                    controller.onOTPChanged(
                                      index,
                                      value,
                                      context,
                                    );
                                  },
                                  controller: controller.textControllers[index],
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.verifyOTP,
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Verify Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.grey),
                            children: <TextSpan>[
                              const TextSpan(
                                text: "Didn't you receive any code? ",
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: 'Resend Code',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = controller.isLoading.value
                                      ? null
                                      : () {
                                          controller.resendOTP();
                                        },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
