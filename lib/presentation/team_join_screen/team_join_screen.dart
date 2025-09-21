import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';
import '../../core/app_export.dart';
import './widgets/benefits_section_widget.dart';
import './widgets/create_team_card_widget.dart';
import './widgets/join_team_card_widget.dart';
import './widgets/success_modal_widget.dart';

class TeamJoinScreen extends StatefulWidget {
  const TeamJoinScreen({super.key});

  @override
  State<TeamJoinScreen> createState() => _TeamJoinScreenState();
}

class _TeamJoinScreenState extends State<TeamJoinScreen>
    with TickerProviderStateMixin {
  bool _isJoinLoading = false;
  bool _isCreateLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late SupabaseClient supabase;
  User? currentUser;
  late String currentUserId;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    supabase = SupabaseService.instance.client;
    currentUser = supabase.auth.currentUser;
    currentUserId = currentUser?.id ?? '';
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinTeam(String code) async {
    if (mounted) setState(() => _isJoinLoading = true);
    HapticFeedback.lightImpact();
    try {
      if (currentUser == null) {
        _showErrorSnackBar('Authentication error. Please log in again.');
        return;
      }

      final teamResponse = await supabase
          .from('teams')
          .select('id, name')
          .eq('invitation_code', code.trim())
          .single();

      final teamId = teamResponse['id'] as String;
      final teamName = teamResponse['name'] as String;

      final memberCheck = await supabase
          .from('team_members')
          .select()
          .eq('user_id', currentUserId);

      if (memberCheck.isNotEmpty) {
        _showErrorSnackBar('You are already a member of another team.');
        return;
      }

      await supabase.from('team_members').insert({
        'team_id': teamId,
        'user_id': currentUserId,
        'invitation_status': 'accepted',
      });

      _showSuccessModal(
        title: 'Joined Successfully!',
        message: 'You have successfully joined "$teamName".',
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/calendar-dashboard');
        },
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('Cannot coerce')) {
        _showErrorSnackBar(
            'Invalid invitation code. Please check and try again.');
      } else {
        _showErrorSnackBar('An error occurred: ${e.message}');
      }
    } catch (_) {
      _showErrorSnackBar(
          'Network error. Please check your connection and try again.');
    } finally {
      if (mounted) setState(() => _isJoinLoading = false);
    }
  }

  Future<void> _handleCreateTeam(String teamName) async {
    if (mounted) setState(() => _isCreateLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (currentUser == null) {
        _showErrorSnackBar('Authentication error. Please log in again.');
        return;
      }
      final teamData = await supabase
          .from('teams')
          .insert({
            'name': teamName.trim(),
            'owner_id': currentUserId,
          })
          .select()
          .single();

      final teamId = teamData['id'] as String;

      await supabase.from('team_members').insert({
        'team_id': teamId,
        'user_id': currentUserId,
        'role': 'admin',
        'invitation_status': 'accepted',
      });

      HapticFeedback.heavyImpact();
      _showSuccessModal(
        title: 'Team Created Successfully!',
        message:
            'Your team "$teamName" has been created. Share the invitation code below with your team members.',
        invitationCode: teamData['invitation_code'] as String?,
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/calendar-dashboard');
        },
        onShare: () => _shareInvitationCode(
          teamData['invitation_code'] as String,
          teamName,
        ),
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('unique_violation')) {
        _showErrorSnackBar('Team with this name already exists.');
      } else {
        _showErrorSnackBar('An error occurred: ${e.message}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create team. Please try again.');
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isCreateLoading = false);
    }
  }

  void _shareInvitationCode(String code, String teamName) {
    final shareText =
        'Join my team "$teamName" on TeamSync Calendar!\n\nInvitation Code: $code\n\nDownload the app and use this code to join our team.';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share message copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessModal({
    required String title,
    required String message,
    String? invitationCode,
    required VoidCallback onContinue,
    VoidCallback? onShare,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessModalWidget(
        title: title,
        message: message,
        invitationCode: invitationCode,
        onContinue: onContinue,
        onShare: onShare,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.lightTheme.colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Join Team',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Header Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get Started with TeamSync',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Join an existing team or create a new one to start collaborating with your colleagues.',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Join Team Card
                  JoinTeamCardWidget(
                    onJoinTeam: _handleJoinTeam,
                    isLoading: _isJoinLoading,
                  ),

                  SizedBox(height: 2.h),

                  // Create Team Card
                  CreateTeamCardWidget(
                    onCreateTeam: _handleCreateTeam,
                    isLoading: _isCreateLoading,
                  ),

                  SizedBox(height: 3.h),

                  const BenefitsSectionWidget(),

                  SizedBox(height: 2.h),

                  // Help Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'How to share invitation codes',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.h),
                          Text(
                            '• Share via messaging apps, email, or social media\n• Team members can join instantly with the code\n• Codes are secure and unique to each team\n• You can regenerate codes anytime from team settings',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
