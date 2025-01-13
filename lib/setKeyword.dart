import 'package:flutter/material.dart';

class KeywordSettingsPage extends StatefulWidget {
  const KeywordSettingsPage({
    super.key,
    required this.initialKeywords,
  });

  final List<String> initialKeywords;

  @override
  State<KeywordSettingsPage> createState() => _KeywordSettingsPageState();
}

class _KeywordSettingsPageState extends State<KeywordSettingsPage> {
  late List<String> keywords; // 모든 키워드
  late List<String> selectedKeywords; // 선택된 키워드

  final TextEditingController _keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    keywords = [...widget.initialKeywords];
    selectedKeywords = [...widget.initialKeywords];
  }

  void _addKeyword() {
    final keyword = _keywordController.text.trim();
    if (keyword.isNotEmpty && !keywords.contains(keyword)) {
      setState(() {
        keywords.add(keyword);
        selectedKeywords.add(keyword);
      });
      _keywordController.clear();
    }
  }

  void _toggleKeyword(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        selectedKeywords.add(keyword);
      }
    });
  }

  void _resetKeywords() {
    setState(() {
      selectedKeywords = [...widget.initialKeywords];
    });
  }

  void _saveKeywords() {
    // 저장 로직 추가 가능
    Navigator.pop(context, selectedKeywords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("키워드 설정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("키워드 직접 추가", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      hintText: "키워드를 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addKeyword,
                  child: const Text("추가"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((keyword) {
                final isSelected = selectedKeywords.contains(keyword);
                return GestureDetector(
                  onTap: () => _toggleKeyword(keyword),
                  child: Chip(
                    label: Text(keyword),
                    backgroundColor:
                        isSelected ? Colors.brown[300] : Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _resetKeywords,
              child: const Text(
                "초기화",
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton(
              onPressed: _saveKeywords,
              child: const Text("저장"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
