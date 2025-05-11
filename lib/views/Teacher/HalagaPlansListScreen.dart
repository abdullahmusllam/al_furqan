import 'package:al_furqan/models/halaga_model.dart';
import 'package:flutter/material.dart';

import 'HalagaPlansScreen.dart';
// import 'package:provider/provider.dart';
// import '../../controllers/QuranPlansSyncController.dart';
// import '../../models/ConservationPlan.dart';
// import '../../models/EltlawahPlan.dart';

class HalagaPlansListScreen extends StatefulWidget {
  HalagaModel halaga;
  HalagaPlansListScreen({Key? key, required this.halaga}) : super(key: key);

  @override
  _HalagaPlansListScreenState createState() =>
      _HalagaPlansListScreenState(halagaModel: halaga);
}

class _HalagaPlansListScreenState extends State<HalagaPlansListScreen> {
  HalagaModel halagaModel;
  _HalagaPlansListScreenState({required this.halagaModel});
  // late QuranPlansSyncController _plansController;
  bool _isLoading = true;
  // List<ConservationPlan> _conservationPlans = [];
  // List<EltlawahPlan> _tlawahPlans = [];

  @override
  void initState() {
    super.initState();
    // _plansController = Provider.of<QuranPlansSyncController>(context, listen: false);
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      // _conservationPlans = await _plansController.getConservationPlans();
      // _tlawahPlans = await _plansController.getEltlawahPlans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل الخطط: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خطط الحلقات'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'خطط الحفظ'),
              Tab(text: 'خطط التلاوة'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildConservationPlansList(),
                  _buildTlawahPlansList(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Add navigation to create new plan screen
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddHalagaPlansScreen(
                      halaga: halagaModel,
                    )));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildConservationPlansList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        // final plan = _conservationPlans[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('خطة الحفظ ${index}'),
            subtitle: Text('معدل التنفيذ: ${index}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Add navigation to edit plan screen
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // _showDeleteConfirmationDialog(plan);
                  },
                ),
              ],
            ),
            onTap: () {
              // TODO: Add navigation to plan details screen
            },
          ),
        );
      },
    );
  }

  Widget _buildTlawahPlansList() {
    // if (_tlawahPlans.isEmpty) {
    //   return const Center(child: Text('لا توجد خطط تلاوة'));
    // }

    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        // final plan = _tlawahPlans[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('خطة التلاوة ${index}'),
            subtitle: Text('معدل التنفيذ: ${index}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Add navigation to edit plan screen
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // _showDeleteConfirmationDialog(plan);
                  },
                ),
              ],
            ),
            onTap: () {
              // TODO: Add navigation to plan details screen
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(dynamic plan) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الخطة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    // if (result == true) {
    //   try {
    //     if (plan is ConservationPlan) {
    //       await _plansController.deleteConservationPlan(plan);
    //     } else if (plan is EltlawahPlan) {
    //       await _plansController.deleteEltlawahPlan(plan);
    //     }
    //     await _loadPlans();
    //   } catch (e) {
    //     if (mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('حدث خطأ في حذف الخطة: ${e.toString()}')),
    //       );
    //     }
    //   }
    // }
  }
}
