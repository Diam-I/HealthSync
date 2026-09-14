import 'package:flutter/material.dart';
import 'package:healthsync/features/patient/services/patient_service.dart';
import 'package:healthsync/models/patient.dart';
import 'package:healthsync/features/notes/pages/notes_page.dart';
import 'package:healthsync/features/notes/services/note_service.dart';

class PatientPage extends StatelessWidget {
  final PatientService patientService;
  final NoteService noteService;

  const PatientPage({
    super.key,
    required this.patientService,
    required this.noteService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informations du patient"),
        centerTitle: true,
      ),
      // A bottom to go to the notes page //
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Patient'),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => NotesPage(
                  noteService: noteService,
                  patientService: patientService,
                ),
              ),
            );
          }
        },
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final patients = await patientService.getAllPatients();

              if (!context.mounted) return;

              if (patients.isNotEmpty) {
                final patient = patients.first;
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Carte du patient"),
                    content: Text(
                      "Nom: ${patient.lastName}\nPrénom: ${patient.firstName}\nSexe: ${patient.gender}\nDate de naissance: ${patient.dateOfBirth}\nAdresse: ${patient.address}\nNuméro de téléphone: ${patient.phone}\nEmail: ${patient.email}\nTaille: ${patient.height} cm\nPoids: ${patient.weight} kg\nGroupe sanguin: ${patient.bloodType}",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Fermer"),
                      ),
                    ],
                  ),
                );
                return;
              }

              final newPatient = await showDialog<Patient>(
                context: context,
                builder: (dialogContext) {
                  final formKey = GlobalKey<FormState>();
                  final firstNameController = TextEditingController();
                  final lastNameController = TextEditingController();
                  final genderController = TextEditingController();
                  final dateOfBirthController = TextEditingController();
                  final addressController = TextEditingController();
                  final phoneController = TextEditingController();
                  final emailController = TextEditingController();
                  final heightController = TextEditingController();
                  final weightController = TextEditingController();
                  final bloodTypeController = TextEditingController();

                  return AlertDialog(
                    title: const Text("Créer un nouveau patient"),
                    content: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: "Prénom",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Veuillez entrer le prénom";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: "Nom",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Veuillez entrer le nom";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: genderController,
                              decoration: const InputDecoration(
                                labelText: "Sexe",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: dateOfBirthController,
                              decoration: const InputDecoration(
                                labelText: "Date de naissance",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                labelText: "Adresse",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: "Téléphone",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: heightController,
                              decoration: const InputDecoration(
                                labelText: "Taille (cm)",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: weightController,
                              decoration: const InputDecoration(
                                labelText: "Poids (kg)",
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: bloodTypeController,
                              decoration: const InputDecoration(
                                labelText: "Groupe sanguin",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final generatedId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            Navigator.of(dialogContext).pop(
                              Patient(
                                id: generatedId,
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                gender: genderController.text.trim(),
                                dateOfBirth: dateOfBirthController.text.trim(),
                                address: addressController.text.trim(),
                                phone: phoneController.text.trim(),
                                email: emailController.text.trim(),
                                height: heightController.text.trim(),
                                weight: weightController.text.trim(),
                                bloodType: bloodTypeController.text.trim(),
                              ),
                            );
                          }
                        },
                        child: const Text("Créer"),
                      ),
                    ],
                  );
                },
              );

              if (newPatient != null) {
                await patientService.addPatient(newPatient);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Patient créé avec succès")),
                );
              }
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
          child: const Text("Afficher mes informations"),
        ),
      ),
      // Update Patient Info //
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final patients = await patientService.getAllPatients();

            if (!context.mounted) return;

            if (patients.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Aucun patient trouvé. Créez-en un."),
                ),
              );
              return;
            }

            // Give the patient information and let the user update it //
            final patient = patients.first;
            final firstNameController = TextEditingController(
              text: patient.firstName,
            );
            final lastNameController = TextEditingController(
              text: patient.lastName,
            );
            final phoneController = TextEditingController(text: patient.phone);
            final emailController = TextEditingController(text: patient.email);
            final addressController = TextEditingController(
              text: patient.address,
            );
            final genderController = TextEditingController(
              text: patient.gender,
            );
            final dateOfBirthController = TextEditingController(
              text: patient.dateOfBirth,
            );
            final heightController = TextEditingController(
              text: patient.height,
            );
            final weightController = TextEditingController(
              text: patient.weight,
            );
            final bloodTypeController = TextEditingController(
              text: patient.bloodType,
            );

            final updatedPatient = await showDialog<Patient>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text("Modifier les informations du patient"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(labelText: "Prénom"),
                      ),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(labelText: "Nom"),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Téléphone",
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Adresse"),
                      ),
                      TextField(
                        controller: genderController,
                        decoration: const InputDecoration(labelText: "Sexe"),
                      ),
                      TextField(
                        controller: dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: "Date de naissance",
                        ),
                      ),
                      TextField(
                        controller: bloodTypeController,
                        decoration: const InputDecoration(
                          labelText: "Groupe sanguin",
                        ),
                      ),
                      TextField(
                        controller: heightController,
                        decoration: const InputDecoration(
                          labelText: "Taille (cm)",
                        ),
                      ),
                      TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: "Poids (kg)",
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () {
                      // On crée le patient mis à jour avec les valeurs du formulaire
                      Navigator.pop(
                        dialogContext,
                        Patient(
                          id: patient.id,
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          gender: genderController.text.trim(),
                          dateOfBirth: dateOfBirthController.text.trim(),
                          address: addressController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          height: heightController.text.trim(),
                          weight: weightController.text.trim(),
                          bloodType: bloodTypeController.text.trim(),
                        ),
                      );
                    },
                    child: const Text("Enregistrer"),
                  ),
                ],
              ),
            );

            if (updatedPatient != null) {
              await patientService.updatePatient(updatedPatient);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Patient mis à jour avec succès")),
              );
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },

        child: const Icon(Icons.edit),
      ),
    );
  }
}
