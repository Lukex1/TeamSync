import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teamsync_calendar/services/supabase_service.dart';

class ChangeAvatarButton extends StatelessWidget {
  final String userId;
  const ChangeAvatarButton({super.key, required this.userId});

  Future<void> _pickAndUploadAvatar(BuildContext context, String userId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final path = 'avatars/$userId.png';
    final supabase = SupabaseService.instance.client;
    final storage = supabase.storage.from('avatars'); // Twój bucket

    try {
      // Usuń istniejący plik, jeśli istnieje
      final existingFiles = await storage.list(path: 'avatars');
      if (existingFiles.any((f) => f.name == '$userId.png')) {
        await storage.remove([path]);
      }

      // Upload pliku
      await storage.uploadBinary(path, bytes);

      // Pobierz publiczny URL avatara
      final url = storage.getPublicUrl(path);

      // Zaktualizuj avatar w profilu użytkownika
      await supabase.from('user_profiles').update({
        'avatar_url': url,
      }).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar został zaktualizowany!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd uploadu avatara: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () => _pickAndUploadAvatar(context, userId),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Change avatar'));
  }
}
