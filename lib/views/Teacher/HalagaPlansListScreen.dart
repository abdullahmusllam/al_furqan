import 'package:al_furqan/controllers/plan_controller.dart';
import 'package:al_furqan/models/conservation_plan_model.dart';
import 'package:al_furqan/models/eltlawah_plan_model.dart';
import 'package:al_furqan/models/halaga_model.dart';
import 'package:al_furqan/models/islamic_studies_model.dart';
import 'package:flutter/material.dart';
import 'HalagaPlansScreen.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      await planController.getPlans(halagaModel.halagaID!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل الخطط: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('خطط الحلقة: ${halagaModel.Name ?? ""}'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'خطط الحفظ'),
              Tab(text: 'خطط التلاوة'),
              Tab(text: 'خطط العلوم الشرعية'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildConservationPlansList(),
            _buildTlawahPlansList(),
            _buildIslamicStudyPlansList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddHalagaPlansScreen(halaga: halagaModel),
              ),
            );
            if (result == true) {
              _loadPlans(); // تحديث القوائم بعد إضافة خطط جديدة
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildConservationPlansList() {
    List<ConservationPlanModel> planC = planController.conservationPlans;
    if (planC.isEmpty) {
      return const Center(child: Text('لا توجد خطط حفظ متاحة'));
    }
    return ListView.builder(
      itemCount: planC.length,
      itemBuilder: (context, index) {
        final plan = planC[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('خطة شهر ${plan.planMonth ?? 'غير محدد'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('من: ${plan.plannedStartSurah}، آية: ${plan.plannedStartAya ?? 0}'),
                Text('إلى: ${plan.plannedEndSurah}، آية: ${plan.plannedEndAya ?? 0}'),
                Text('معدل التنفيذ: ${(plan.executedRate ?? 0) * 100}%'),
                Text('المزامنة: ${plan.isSync == 1 ? 'تمت' : 'لم تتم'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editPlan(context, plan);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      plan.conservationPlanId!,
                      "ConservationPlans",
                      "ConservationPlanID",
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              // يمكن إضافة تفاصيل الخطة هنا
            },
          ),
        );
      },
    );
  }

  Widget _buildTlawahPlansList() {
    List<EltlawahPlanModel> planE = planController.eltlawahPlans;
    if (planE.isEmpty) {
      return const Center(child: Text('لا توجد خطط تلاوة متاحة'));
    }
    return ListView.builder(
      itemCount: planE.length,
      itemBuilder: (context, index) {
        final plan = planE[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('خطة شهر ${plan.planMonth ?? 'غير محدد'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('من: ${plan.plannedStartSurah}، آية: ${plan.plannedStartAya ?? 0}'),
                Text('إلى: ${plan.plannedEndSurah}، آية: ${plan.plannedEndAya ?? 0}'),
                Text('معدل التنفيذ: ${(plan.executedRate ?? 0) * 100}%'),
                Text('المزامنة: ${plan.isSync == 1 ? 'تمت' : 'لم تتم'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editPlan(context, plan);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      plan.eltlawahPlanId!,
                      "EltlawahPlans",
                      "EltlawahPlanID",
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              // يمكن إضافة تفاصيل الخطة هنا
            },
          ),
        );
      },
    );
  }

  Widget _buildIslamicStudyPlansList() {
    List<IslamicStudiesModel> planI = planController.islamicStudyPlans;
    if (planI.isEmpty) {
      return const Center(child: Text('لا توجد خطط علوم شرعية متاحة'));
    }
    return ListView.builder(
      itemCount: planI.length,
      itemBuilder: (context, index) {
        final plan = planI[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('خطة شهر ${plan.planMonth ?? 'غير محدد'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المقرر: ${plan.subject}'),
                Text('المحتوى: ${plan.plannedContent}'),
                Text('المزامنة: ${plan.isSync == 1 ? 'تمت' : 'لم تتم'}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editPlan(context, plan);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      plan.islamicStudiesID!,
                      "IslamicStudies",
                      "IslamicStudiesID",
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              // يمكن إضافة تفاصيل الخطة هنا
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      int planID, String table, String column) async {
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
            onPressed: () async {
              try {
                await planController.deletePlan(planID, table, column);
                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')),
                );
                Navigator.of(context).pop(false);
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الخطة بنجاح')),
      );
      await _loadPlans(); // تحديث القوائم بعد الحذف
    }
  }

  void _editPlan(BuildContext context, dynamic plan) {
    // الانتقال إلى شاشة التعديل (نستخدم AddHalagaPlansScreen مع بيانات الخطة)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHalagaPlansScreen(halaga: halagaModel),
      ),
    ).then((result) {
      if (result == true) {
        _loadPlans(); // تحديث القوائم بعد التعديل
      }
    });
  }
}