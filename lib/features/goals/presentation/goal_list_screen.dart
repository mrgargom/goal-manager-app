import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/goal_provider.dart';
import '../../auth/state/auth_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../data/goal_model.dart';
import 'add_goal_screen.dart';
import 'widgets/goal_card.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({Key? key}) : super(key: key);

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch(GoalProvider provider) {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    provider.setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search goals...',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) => goalProvider.setSearchQuery(value),
                  )
                : const Text('My Goals'),
            actions: [
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _stopSearch(goalProvider),
                )
              else
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              PopupMenuButton<GoalFilter>(
                initialValue: goalProvider.filter,
                onSelected: (filter) => goalProvider.setFilter(filter),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: GoalFilter.all,
                    child: Text('All'),
                  ),
                  const PopupMenuItem(
                    value: GoalFilter.notStarted,
                    child: Text('Not Started'),
                  ),
                  const PopupMenuItem(
                    value: GoalFilter.inProgress,
                    child: Text('In Progress'),
                  ),
                  const PopupMenuItem(
                    value: GoalFilter.completed,
                    child: Text('Completed'),
                  ),
                ],
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter Goals',
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                    },
                    tooltip: 'Toggle Theme',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                },
                tooltip: 'Sign Out',
              ),
            ],
          ),
          body: StreamBuilder<List<GoalModel>>(
            stream: goalProvider.goalsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final goals = snapshot.data ?? [];

              if (goals.isEmpty) {
                String message = 'No goals yet. Add one!';
                if (goalProvider.searchQuery.isNotEmpty) {
                  message =
                      'No goals found matching "${goalProvider.searchQuery}".';
                } else if (goalProvider.filter != GoalFilter.all) {
                  message = 'No goals found for this filter.';
                }

                return Center(child: Text(message));
              }

              return ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return Dismissible(
                    key: Key(goal.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      goalProvider.deleteGoal(goal.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${goal.title} deleted')),
                      );
                    },
                    child: GoalCard(
                      goal: goal,
                      onEdit: () => _showUpdateProgressDialog(context, goal),
                      onDelete: () =>
                          _confirmDelete(context, goalProvider, goal),
                      searchQuery: goalProvider.searchQuery,
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGoalScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showUpdateProgressDialog(BuildContext context, GoalModel goal) {
    final provider = Provider.of<GoalProvider>(context, listen: false);
    double currentProgress = goal.progress.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Progress: ${goal.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${currentProgress.round()}%'),
                  Slider(
                    value: currentProgress,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: currentProgress.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        currentProgress = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.updateProgress(goal, currentProgress.round());
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    GoalProvider provider,
    GoalModel goal,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteGoal(goal.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${goal.title} deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
