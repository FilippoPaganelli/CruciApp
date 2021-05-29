// class for definitions to be shown for letter at index, with reference to the related words
// if no definition/word is to be shown, it will get "-" as a value
class Definition {
  final int index;
  final String hDef;
  final String hWord;
  final String vDef;
  final String vWord;

  Definition(this.index, this.hDef, this.hWord, this.vDef, this.vWord);
}
