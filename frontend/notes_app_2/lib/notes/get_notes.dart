import 'package:flutter/material.dart';
import 'package:notes_app_2/notes/create_note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:notes_app_2/notes/update_note.dart';

class GetNotesScreen extends StatefulWidget {
  const GetNotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GetNotesScreenState createState() => _GetNotesScreenState();
}

class _GetNotesScreenState extends State<GetNotesScreen> {
  final PagingController<int, dynamic> _pagingController = PagingController(
    firstPageKey: 1,
  );

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final dio = Dio();
      final url = 'http://localhost:3000/notes?page=$pageKey&page_size=5';
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          },
        ),
      );
      final List<dynamic> data = response.data['data'];
      final isLastPage = data.isEmpty;
      if (isLastPage) {
        _pagingController.appendLastPage(data);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
      if (error is DioException && error.response?.statusCode == 404) {
        _pagingController.appendLastPage([]);
      }
    }
  }

  void deleteTour(dynamic id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await Dio().delete(
        'http://localhost:3000/notes/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          },
        ),
      );

      print(response.data);

      if (response.statusCode == 200) {
        _pagingController.refresh();
      }
    } catch (error) {
      print('Terjadi kesalahan saat melakukan permintaan: $error');
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Center(
            heightFactor: 2,
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateNotesScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: Text(
                    'Buat catatan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const FractionallySizedBox(
            widthFactor: 0.75,
            child: Text(
              'Daftar Catatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, dynamic>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, item, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FractionallySizedBox(
                        widthFactor: 0.75,
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text(item['description']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => UpdateNoteScreen(
                                                noteId: item['id'],
                                              ),
                                        ),
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                            'Apakah Anda yakin ingin menghapus catatan ini?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Tutup dialog
                                              },
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteTour(
                                                  item['id'],
                                                ); // Hapus catatan
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Tutup dialog
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}