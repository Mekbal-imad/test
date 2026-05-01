import 'package:flutter/material.dart';
import 'package:job_bit/widgets/custom_form_field.dart';

class BusinessInfoCard extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController? emailController;
  final TextEditingController? websiteController;

  const BusinessInfoCard({
    super.key,
    required this.phoneController,
    this.emailController,
    this.websiteController,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //!header title of card
Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                children: [
Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business,
                      color: cs.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Contact Information", 
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

const SizedBox(height: 20),

            CustomFormField(
              label: "Phone *",
              hint: "+213 78 292 4307",
              controller: phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),

            if (emailController != null)
              CustomFormField(
                label: "Email",
                hint: "jobs@business.com",
                controller: emailController!,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isRequired: false,
              ),

            if (websiteController != null)
              CustomFormField(
                label: "Website",
                hint: "https://www.business.com",
                controller: websiteController!,
                icon: Icons.language,
                isRequired: false,
              ),
          ],
        ),
      ),
    );
  }
}
