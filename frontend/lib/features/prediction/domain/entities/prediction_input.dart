/// Input prediksi dengan vocabulary dataset SleepWise (bukan field bebas UI).
///
/// Nama field = nama kolom dataset, jadi payload API dibuat 1:1 tanpa
/// terjemahan tambahan dan tanpa field yang tidak dikenal model.
class PredictionInput {
  final String gender; // 'Male' | 'Female'
  final int age;
  final String occupation;
  final double sleepDuration; // jam
  final int physicalActivityLevel; // menit aktivitas fisik per hari
  final int stressLevel; // 1..10
  final String bmiCategory; // Underweight | Normal | Overweight | Obese
  final int heartRate; // bpm
  final int dailySteps;
  final int systolicBp;
  final int diastolicBp;

  const PredictionInput({
    required this.gender,
    required this.age,
    required this.occupation,
    required this.sleepDuration,
    required this.physicalActivityLevel,
    required this.stressLevel,
    required this.bmiCategory,
    required this.heartRate,
    required this.dailySteps,
    required this.systolicBp,
    required this.diastolicBp,
  });
}
