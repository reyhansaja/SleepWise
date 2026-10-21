import 'package:flutter/material.dart';

import '../../../../core/navigation/app_routes.dart';
import '../widgets/circadian_hero_graphic.dart';
import '../widgets/landing_action_button.dart';
import '../widgets/landing_content.dart';
import '../widgets/landing_header.dart';

/// Landing page displayed when the SleepWise application is launched.
/// Provides an onboarding overview and navigates to the login page upon tapping "Lanjut".
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.22),
            radius: 1.15,
            colors: [
              Color(0xFF141C32),
              Color(0xFF0A0E1A),
              Color(0xFF070912),
            ],
            stops: [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Section: Header
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
                          child: LandingHeader(),
                        ),

                        // Center Section: Hero Graphic & Text Content
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Concentric Circadian Graphic
                            CircadianHeroGraphic(
                              size: (constraints.maxHeight * 0.26).clamp(160.0, 240.0),
                            ),
                            const SizedBox(height: 20),

                            // Tag, Headlines, and Subtitle
                            const LandingContent(),
                          ],
                        ),

                        // Bottom Section: Action Button and Copyright Footer
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0, bottom: 14.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LandingActionButton(
                                onPressed: () => _navigateToLogin(context),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '© 2026 SleepWise • On-Device AI Sleep Assistant',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
