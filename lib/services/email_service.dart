import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  final String _username =
      'celestialscommunication@gmail.com';
  final String _password =
      'ltih murt nuxs ywjo';

  Future<void> sendSpellCastEmail({
    required String enemyName,
    required String enemyEmail,
    required double intensity,
    required String spellName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Error: Caster not logged in.");
      return;
    }
    String _getIntensityText() {
      if (intensity <= 2) return 'Mild Curse';
      if (intensity <= 4) return 'Dark Wish';
      if (intensity <= 6) return 'Deadly Curse';
      if (intensity <= 8) return 'Ancient Hex';
      return 'Ultimate Doom';
    }

    //Using the simpler gmail() SMTP configuration
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'The Para Coven')
      ..recipients.add(enemyEmail)
      ..subject = 'A Shadow Falls Upon You, $enemyName!'
      ..html =
          """
        <body style="font-family: 'Courier New', monospace; background-color: #0a0a0a; color: #E0E0E0; padding: 20px;">
    <div
        style="max-width: 600px; margin: auto; background-color: #1E1E1E; padding: 30px; border-radius: 2px; border: 1px solid #5a0000;">
        <h2 style="color: #DC143C; text-align: center; font-family: 'Creepster', cursive; letter-spacing: 4px;">You Have
            Been Cursed️‼️</h2>
        <p>Greetings $enemyName,</p>
        <p>A ritual has been completed. Your name now beats in the heart of this curse — and it will not stop until yours does..
        </p>
        <p>A <strong>$spellName</strong> curse of intensity <strong>${intensity.toInt()}/10 (${_getIntensityText()})</strong> has been sealed.
        </p>
        
        <p>The threads of destiny have been re-spun. Good luck.</p>

        <!-- UPDATED SECTION -->
        <br><br>
        <p style="margin-top: 30px; text-align: center;">If you need to cast some spells, download our app -- Para App
            by clicking the icon below.</p>
        <div style="text-align: center; margin-top: 20px;">
            <!-- The href now points to your GitHub release download link -->
            <a href="https://github.com/yoAlienX/paara_app/releases/download/v1.0.0/para.apk" target="_blank">
                <!-- The src now points to your icon in the repo -->
                <img src="https://raw.githubusercontent.com/yoAlienX/paara_app/main/assets/icon/dp.png"
                    alt="Para App Icon" style="width: 60px; height: 60px; border-radius: 15px;">
            </a>
        </div>
        <!-- END OF UPDATED SECTION -->

        <br>
        <p style="text-align: right; font-style: italic;">— The Para Coven</p>
    </div>
</body>
      """;

    try {
      print('Attempting to send curse email to $enemyEmail...');
      final sendReport = await send(message, smtpServer);
      print('Curse email sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Curse email not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
