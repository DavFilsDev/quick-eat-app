/// Formate une durée écoulée depuis [date] en texte court en français,
/// utilisé sur les badges "Il y a X min" (Accueil Commerçant, Commandes).
class TimeAgoFormatter {
  TimeAgoFormatter._();

  static String format(DateTime date, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final Duration diff = reference.difference(date);

    if (diff.inSeconds < 60) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }
}
