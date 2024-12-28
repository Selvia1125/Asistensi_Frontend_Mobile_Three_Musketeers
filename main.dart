import 'package:flutter/material.dart';

void main() {
  runApp(TaskProApp());
}

class TaskProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TaskManager taskManager = TaskManager();
    taskManager
        .addTask(Task(title: 'Tugas Mobile', description: 'Belajar Flutter'));
    taskManager.addTask(Task(title: 'Tugas Mobile', description: 'Membuat UI'));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      home: HomePage(taskManager: taskManager),
    );
  }
}

class Task {
  String title;
  String description;
  String status;
  List<String> progressNotes;

  Task({
    required this.title,
    required this.description,
    this.status = 'In Progress',
    this.progressNotes = const [],
  });
}

class TaskManager {
  List<Task> tasks = [];

  void addTask(Task task) {
    tasks.add(task);
  }

  void updateTaskStatus(int index, String status) {
    tasks[index].status = status;
  }

  void addProgressToTask(int index, String progressNote) {
    tasks[index].progressNotes.add(progressNote);
  }
}

class HomePage extends StatelessWidget {
  final TaskManager taskManager;

  HomePage({required this.taskManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard TaskPro'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Daftar Tugas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TaskListPage(taskManager: taskManager),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              title: Text('Notifikasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://i0.wp.com/dimensipers.com/wp-content/uploads/2020/03/online-learning-background-with-computer-person-studying_23-2147593692.jpg?fit=899%2C626&ssl=1'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'Selamat Datang di TaskPro',
              style: TextStyle(
                  fontSize: 50, color: const Color.fromARGB(255, 12, 12, 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListPage extends StatefulWidget {
  final TaskManager taskManager;

  TaskListPage({required this.taskManager});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.taskManager.tasks.isEmpty
            ? Center(
                child: Text(
                  'Belum ada tugas!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: widget.taskManager.tasks.length,
                itemBuilder: (context, index) {
                  final task = widget.taskManager.tasks[index];
                  return Card(
                    color: task.status == 'Completed'
                        ? Colors.teal[50]
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(task.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Deskripsi: ${task.description}',
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text('Status: ${task.status}',
                                style: TextStyle(
                                    color: Colors.teal[800],
                                    fontWeight: FontWeight.w600)),
                            if (task.progressNotes.isNotEmpty)
                              Text('Progres: ${task.progressNotes.join(', ')}',
                                  style: TextStyle(color: Colors.teal[700])),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'Mark Completed') {
                              setState(() {
                                widget.taskManager
                                    .updateTaskStatus(index, 'Completed');
                              });
                            } else if (value == 'Add Progress') {
                              _showProgressDialog(context, index);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Mark Completed',
                              child: Text('Tandai Selesai'),
                            ),
                            PopupMenuItem(
                              value: 'Add Progress',
                              child: Text('Tambah Progres'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showProgressDialog(BuildContext context, int index) {
    final TextEditingController _progressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Progres', style: TextStyle(color: Colors.teal)),
          content: TextField(
            controller: _progressController,
            decoration: InputDecoration(
              hintText: 'Masukkan catatan progres',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_progressController.text.isNotEmpty) {
                  setState(() {
                    widget.taskManager.addProgressToTask(
                      index,
                      _progressController.text,
                    );
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Catatan progres tidak boleh kosong')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar pengguna
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6SMte5ebTwzB9X4QW2s0UKDxr1Le75BUfwg&s',
                ),
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(height: 16),
              // Nama pengguna
              Text(
                'Three Musketeers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Email pengguna
              Text(
                'threemusketeers@gmail.com',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              // Tombol Edit Profil
              ElevatedButton.icon(
                onPressed: () {
                  // Logika untuk mengedit profil
                },
                icon: Icon(Icons.edit),
                label: Text('Edit Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              SizedBox(height: 16),
              // Tombol Logout
              OutlinedButton.icon(
                onPressed: () {
                  // Logika untuk logout
                },
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://i0.wp.com/dimensipers.com/wp-content/uploads/2020/03/online-learning-background-with-computer-person-studying_23-2147593692.jpg?fit=899%2C626&ssl=1'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Text('Halaman Notifikasi',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
