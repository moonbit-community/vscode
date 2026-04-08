///|
pub(all) enum CharacterClass {
  Regular
  WordSeparator
  Whitespace
} derive(Eq)

///|
pub(all) enum WordType {
  Empty
  Separator
  Regular
} derive(Eq)

///|
type WordCharacters = Array[CharacterClass]

///|
pub struct Word {
  start : Int
  end_index : Int
  word_type : WordType
}

///|
fn character_class_at(
  word_character_class : WordCharacters,
  ch_code : Int,
) -> CharacterClass {
  if ch_code >= 0 && ch_code < word_character_class.length() {
    word_character_class[ch_code]
  } else {
    CharacterClass::Regular
  }
}

///|
pub fn create_word_characters(word_separators : String) -> WordCharacters {
  let result = Array::make(256, CharacterClass::Regular)
  for i in 0..<word_separators.length() {
    result[word_separators[i].to_int()] = CharacterClass::WordSeparator
  }
  result[' '.to_int()] = CharacterClass::Whitespace
  result['\t'.to_int()] = CharacterClass::Whitespace
  result
}

///|
fn find_start_of_word(
  line_content : String,
  word_character_class : WordCharacters,
  word_type : WordType,
  start_index : Int,
) -> Int {
  let mut ch_index = start_index
  while ch_index >= 0 {
    let ch_class = character_class_at(
      word_character_class,
      line_content[ch_index].to_int(),
    )
    if ch_class == CharacterClass::Whitespace {
      return ch_index + 1
    }
    if word_type == WordType::Regular &&
      ch_class == CharacterClass::WordSeparator {
      return ch_index + 1
    }
    if word_type == WordType::Separator && ch_class == CharacterClass::Regular {
      return ch_index + 1
    }
    ch_index -= 1
  }
  0
}

///|
fn make_word(
  line_content : String,
  word_type : WordType,
  start : Int,
  end_index : Int,
) -> Word {
  let _ = line_content
  Word::{ start, end_index, word_type }
}

///|
pub fn find_next_word(
  doc : @vscode.TextDocument,
  pos : @vscode.Position,
  word_character_class : WordCharacters,
) -> Word? {
  let line_content = doc.line_at_line(pos.line()).text
  let mut word_type = WordType::Empty
  let len = line_content.length()
  for ch_index in pos.character()..<len {
    let ch_class = character_class_at(
      word_character_class,
      line_content[ch_index].to_int(),
    )
    if ch_class == CharacterClass::Regular {
      if word_type == WordType::Separator {
        return Some(
          make_word(
            line_content,
            word_type,
            find_start_of_word(
              line_content,
              word_character_class,
              word_type,
              ch_index - 1,
            ),
            ch_index,
          ),
        )
      }
      word_type = WordType::Regular
    } else if ch_class == CharacterClass::WordSeparator {
      if word_type == WordType::Regular {
        return Some(
          make_word(
            line_content,
            word_type,
            find_start_of_word(
              line_content,
              word_character_class,
              word_type,
              ch_index - 1,
            ),
            ch_index,
          ),
        )
      }
      word_type = WordType::Separator
    } else if word_type != WordType::Empty {
      return Some(
        make_word(
          line_content,
          word_type,
          find_start_of_word(
            line_content,
            word_character_class,
            word_type,
            ch_index - 1,
          ),
          ch_index,
        ),
      )
    }
  }
  if word_type != WordType::Empty {
    Some(
      make_word(
        line_content,
        word_type,
        find_start_of_word(
          line_content,
          word_character_class,
          word_type,
          len - 1,
        ),
        len,
      ),
    )
  } else {
    None
  }
}
