// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'customer_register_controller.dart';

// class CustomerRegisterView extends GetView<CustomerRegisterController> {
//   const CustomerRegisterView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2563EB),
//         automaticallyImplyLeading: false,
//       ),
//       backgroundColor: const Color(0xFFF7F8FA),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Blue background
//             Container(
//               width: double.infinity,
//               height: 220,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF2563EB),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(32),
//                   bottomRight: Radius.circular(32),
//                 ),
//               ),
//             ),
//             // Form content
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 32),
//                   // Title and login link
//                   Column(
//                     children: [
//                       const Text(
//                         'Sign Up',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Already have an account? ',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Get.offAllNamed('/login');
//                             },
//                             child: const Text(
//                               'Log In',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Form(
//                           key: controller.formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               TextFormField(
//                                 controller: controller.nameController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Full Name',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.emailController,
//                                 keyboardType: TextInputType.emailAddress,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Email',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: controller.validateEmail,
//                               ),
//                               const SizedBox(height: 12),
//                               Obx(
//                                 () => DropdownButtonFormField<String>(
//                                   key: ValueKey(
//                                     controller.gender.value.isEmpty
//                                         ? 'gender-null'
//                                         : controller.gender.value,
//                                   ),
//                                   initialValue: controller.gender.value.isEmpty
//                                       ? null
//                                       : controller.gender.value,
//                                   items: const [
//                                     DropdownMenuItem(
//                                       value: 'male',
//                                       child: Text('Male'),
//                                     ),
//                                     DropdownMenuItem(
//                                       value: 'female',
//                                       child: Text('Female'),
//                                     ),
//                                   ],
//                                   onChanged: (v) =>
//                                       controller.gender.value = v ?? '',
//                                   decoration: const InputDecoration(
//                                     labelText: 'Gender',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   validator: (v) => v == null || v.isEmpty
//                                       ? 'Required'
//                                       : null,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.streetController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Street',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.cityController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'City',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.provinceController,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Province',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.dobController,
//                                 readOnly: true,
//                                 decoration: InputDecoration(
//                                   labelText: 'Date of Birth',
//                                   border: const OutlineInputBorder(),
//                                   suffixIcon: IconButton(
//                                     icon: const Icon(Icons.calendar_today),
//                                     onPressed: () =>
//                                         controller.pickDate(context),
//                                   ),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                                 onTap: () => controller.pickDate(context),
//                               ),
//                               const SizedBox(height: 12),
//                               TextFormField(
//                                 controller: controller.accountNumberController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                   labelText: 'Account Number',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 validator: (v) =>
//                                     v == null || v.isEmpty ? 'Required' : null,
//                               ),
//                               const SizedBox(height: 12),
//                               Obx(
//                                 () => DropdownButtonFormField<String>(
//                                   key: ValueKey(
//                                     controller.bank.value.isEmpty
//                                         ? 'bank-null'
//                                         : controller.bank.value,
//                                   ),
//                                   initialValue: controller.bank.value.isEmpty
//                                       ? null
//                                       : controller.bank.value,
//                                   items: controller.bankList
//                                       .map(
//                                         (b) => DropdownMenuItem(
//                                           value: b,
//                                           child: Text(b),
//                                         ),
//                                       )
//                                       .toList(),
//                                   onChanged: (v) =>
//                                       controller.bank.value = v ?? '',
//                                   decoration: const InputDecoration(
//                                     labelText: 'Bank',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   validator: (v) => v == null || v.isEmpty
//                                       ? 'Required'
//                                       : null,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Obx(
//                                 () => TextFormField(
//                                   controller: controller.passwordController,
//                                   obscureText:
//                                       !controller.isPasswordVisible.value,
//                                   decoration: InputDecoration(
//                                     labelText: 'Password',
//                                     border: const OutlineInputBorder(),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         controller.isPasswordVisible.value
//                                             ? Icons.visibility
//                                             : Icons.visibility_off,
//                                       ),
//                                       onPressed:
//                                           controller.togglePasswordVisibility,
//                                     ),
//                                   ),
//                                   validator: controller.validatePassword,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Obx(
//                                 () => SizedBox(
//                                   height: 48,
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF2563EB),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                     onPressed: controller.isLoading.value
//                                         ? null
//                                         : controller.submitRegistration,
//                                     child: controller.isLoading.value
//                                         ? const SizedBox(
//                                             width: 20,
//                                             height: 20,
//                                             child: CircularProgressIndicator(
//                                               strokeWidth: 2,
//                                               valueColor:
//                                                   AlwaysStoppedAnimation(
//                                                     Colors.white,
//                                                   ),
//                                             ),
//                                           )
//                                         : const Text(
//                                             'Register',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
