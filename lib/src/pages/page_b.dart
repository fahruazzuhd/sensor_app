import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sensor_app/src/database/task_db_helper.dart';

class PageB extends StatefulWidget {
  const PageB({Key? key}) : super(key: key);

  @override
  _PageBState createState() => _PageBState();
}

class _PageBState extends State<PageB> {
  List<Map<String, dynamic>> _tasks = [];

  late AndroidDeviceInfo _androidDeviceInfo;
  late IosDeviceInfo _iosDeviceInfo;

  bool _isLoading = true;
  void _refreshTasks() async {
    final data = await TaskDbHelper.getItems();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTasks();
    initDeviceInfo();
  }

  Future<void> initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      _androidDeviceInfo = await deviceInfo.androidInfo;
    } else {
      _iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }

  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _showForm(int? id) async {
    if (id != null) {
      final existingTask = _tasks.firstWhere((element) => element['id'] == id);
      _titleController.text = existingTask['title'];
      _selectedDate = DateTime.parse(existingTask['date']);
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _showDatePicker,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMd().add_jm().format(_selectedDate)),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (id == null) {
                  _addItem();
                } else {
                  _updateItem(id);
                }
                _titleController.text = '';
                _selectedDate = DateTime.now();
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Add Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }


  Future<void> _addItem() async {
    await TaskDbHelper.createItem(
        _titleController.text, _selectedDate);
    _refreshTasks();
  }

  Future<void> _updateItem(int id) async {
    await TaskDbHelper.updateItem(
        id, _titleController.text, _selectedDate);
    _refreshTasks();
  }

  void _deleteItem(int id) async {
    await TaskDbHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task deleted successfully!'),
    ));
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page B'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              //Device Info
              child: FutureBuilder<void>(
                future: initDeviceInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (platform == TargetPlatform.android) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Manufacturer: ${_androidDeviceInfo.manufacturer}'),
                          Text('Model: ${_androidDeviceInfo.model}'),
                          Text('Build Number: ${_androidDeviceInfo.version.release}'),
                          Text('SDK Version: ${_androidDeviceInfo.version.sdkInt}'),
                          Text('Version Code: ${_androidDeviceInfo.version.securityPatch}'),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Manufacturer: ${_iosDeviceInfo.model}'),
                          Text('Model: ${_iosDeviceInfo.name}'),
                          Text('OS Version: ${_iosDeviceInfo.systemVersion}'),
                        ],
                      );
                    }
                  } else {
                    return Center(
                      child: Text('Loading...'),
                    );
                  }
                },
              ),
            ),
            //List task CRUD
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.orange[200],
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      title: Text(_tasks[index]['title']),
                      subtitle: Text(_tasks[index]['date']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showForm(_tasks[index]['id']);
                              } ,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_tasks[index]['id']),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
