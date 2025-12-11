import 'package:car_rental_app/core/gen/assets.gen.dart';
import 'package:car_rental_app/core/theme/colors.dart';
import 'package:car_rental_app/core/theme/dimens.dart';
import 'package:car_rental_app/core/utils/app_navigator.dart';
import 'package:car_rental_app/core/widgets/app_button.dart';
import 'package:car_rental_app/core/widgets/app_list_tile.dart';
import 'package:car_rental_app/core/widgets/app_space.dart';
import 'package:car_rental_app/core/widgets/app_subtitle_text.dart';
import 'package:car_rental_app/core/widgets/app_svg_viewer.dart';
import 'package:car_rental_app/core/widgets/app_text_form_field.dart';
import 'package:car_rental_app/core/widgets/app_title_text.dart';
import 'package:car_rental_app/core/widgets/base_layout.dart';
import 'package:car_rental_app/features/authentication_feature/presentation/bloc/country_selection_cubit.dart';
import 'package:car_rental_app/features/authentication_feature/presentation/screens/country_selection_screen.dart';
import 'package:car_rental_app/features/authentication_feature/presentation/screens/otp_verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Main Widget: Sets up the BlocProvider
class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountrySelectionCubit>(
      create: (context) => CountrySelectionCubit(),
      child: const _MobileLoginContent(),
    );
  }
}

// 2. Content Widget: Handles State (Controllers, Loading, UI)
class _MobileLoginContent extends StatefulWidget {
  const _MobileLoginContent();

  @override
  State<_MobileLoginContent> createState() => _MobileLoginContentState();
}

class _MobileLoginContentState extends State<_MobileLoginContent> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watch = context.watch<CountrySelectionCubit>();

    return BaseLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: AppColors.whiteColor),
        ),
      ),
      // BOTTOM SHEET: The Next Button
      bottomSheet: Padding(
        padding: const EdgeInsets.only(
          bottom: Dimens.largePadding,
          left: Dimens.padding,
          right: Dimens.padding,
        ),
        child: AppButton(
          title: _isLoading ? 'Sending...' : 'Next',
          onPressed: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    if (watch.state.selectedCountry == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please select a country")));
                      return;
                    }

                    setState(() => _isLoading = true);

                    // Create full phone number
                    final phoneNumber = watch.state
                            .countries[watch.state.selectedCountry!]['code'] +
                        _controller.text.trim();

                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: phoneNumber,
                      // 1. Auto Verification (Android only)
                      verificationCompleted:
                          (PhoneAuthCredential credential) async {
                        if (mounted) setState(() => _isLoading = false);
                        // Optional: specific auto-sign-in logic here
                      },
                      // 2. Failed
                      verificationFailed: (FirebaseAuthException e) {
                        if (mounted) setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(e.message ?? "Verification Failed")),
                        );
                      },
                      // 3. Code Sent -> Go to OTP Screen
                      codeSent: (String verificationId, int? resendToken) {
                        if (mounted) setState(() => _isLoading = false);

                        push(
                          context,
                          OtpVerificationScreen(
                            phoneNumber: phoneNumber,
                            verificationId: verificationId,
                          ),
                        );
                      },
                      // 4. Timeout
                      codeAutoRetrievalTimeout: (String verificationId) {
                        if (mounted) setState(() => _isLoading = false);
                      },
                    );
                  }
                },
        ),
      ),
      // BODY: The Form
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.padding),
        child: Column(
          children: [
            const AppVSpace(space: Dimens.extraLargePadding),
            Image.asset(Assets.images.textLogo),
            const AppVSpace(space: Dimens.extraLargePadding),
            const AppTitleText('Login / Register'),
            const AppVSpace(),
            const AppSubtitleText(
              'Please confirm your country code\nand enter your phone number',
            ),
            const AppVSpace(space: Dimens.extraLargePadding),

            // Country Picker
            AppListTile(
              onTap: () {
                push(
                  context,
                  BlocProvider.value(
                    value: context.read<CountrySelectionCubit>(),
                    child: const CountrySelectionScreen(),
                  ),
                );
              },
              title: watch.state.selectedCountry == null
                  ? 'Country'
                  : watch.state.countries[watch.state.selectedCountry!]['name'],
              leading: watch.state.selectedCountry == null
                  ? null
                  : AppSvgViewer(
                      watch.state.countries[watch.state.selectedCountry!]
                          ['flag'],
                    ),
              hasBorder: true,
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    watch.state.selectedCountry == null
                        ? ''
                        : watch.state.countries[watch.state.selectedCountry!]
                            ['code'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const AppHSpace(space: Dimens.padding),
                  AppSvgViewer(Assets.icons.arrowRight1),
                ],
              ),
            ),

            const AppVSpace(space: Dimens.extraLargePadding),

            // Phone Input
            Form(
              key: _formKey,
              child: AppTextFormField(
                controller: _controller,
                labelText: 'Phone number',
                textInputType: TextInputType.phone,
                maxLength: 10,
                validator: (final phoneNumber) {
                  if (phoneNumber == null || phoneNumber.length != 10) {
                    return 'Mobile number must be 10 digits.';
                  }
                  return null;
                },
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(Dimens.padding),
                  child: AppSvgViewer(
                    Assets.icons.call,
                    width: 20,
                  ),
                ),
                prefixText: watch.state.selectedCountry == null
                    ? ''
                    : watch.state.countries[watch.state.selectedCountry!]
                        ['code'],
              ),
            ),
            // Add extra space at bottom so keyboard doesn't cover button
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
