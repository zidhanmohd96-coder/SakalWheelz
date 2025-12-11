import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/services/auth_gate_service.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_scaffold.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_subtitle_text.dart';
import 'package:car_rental_app/core/widgets/app_text_button.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/features/authentication_feature/presentation/widgets/app_pin_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationScreen(
      {super.key, required this.phoneNumber, required this.verificationId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // We need a state variable to hold the ID, because "Resend" might change it.
  late String _currentVerificationId;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
  }

  Future<void> _verifyOtp(String userEnteredOtp) async {
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: userEnteredOtp,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (mounted) {
          // 🚀 Pass control to the Gate Service
          await AuthGateService.checkUserAndNavigate(context, user);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Invalid OTP")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Resending OTP...")));
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Resend Failed: ${e.message}")));
      },
      codeSent: (String newVerificationId, int? token) {
        setState(() {
          _currentVerificationId = newVerificationId;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("New code sent!")));
      },
      codeAutoRetrievalTimeout: (String id) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(Assets.images.otpIllustration, height: 200),
            const AppVSpace(),
            const AppTitleText('Enter code'),
            const AppVSpace(space: Dimens.padding),
            AppSubtitleText(
              "We've sent an SMS with a code to your phone\n${widget.phoneNumber}",
            ),
            const AppVSpace(space: Dimens.extraLargePadding),
            Center(
              child: AppPinInput(
                controller: _pinController,
                focusNode: _pinFocus,
                onChanged: (final code) {
                  if (code.length == 6) {
                    _verifyOtp(code);
                  }
                },
              ),
            ),
            const AppVSpace(space: Dimens.largePadding),
            const AppSubtitleText("Didn't receive code?"),
            AppTextButton(
              title: 'Resend',
              onPressed: _resendOtp,
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: Dimens.largePadding),
        child: AppButton(
          title: _isLoading ? 'Verifying...' : 'Verify & Continue',
          onPressed: _isLoading
              ? null
              : () {
                  if (_pinController.text.length == 6) {
                    _verifyOtp(_pinController.text);
                  }
                },
        ),
      ),
    );
  }
}
