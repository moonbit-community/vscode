var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/extension.ts
var extension_exports = {};
__export(extension_exports, {
  activate: () => activate,
  deactivate: () => deactivate
});
module.exports = __toCommonJS(extension_exports);
var vscode = __toESM(require("vscode"));

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/common.ts
var DeleteRegister = class {
  isWholeLine;
  content;
  constructor(isWholeLine, content) {
    this.isWholeLine = isWholeLine;
    this.content = content;
  }
};
var AbstractCommandDescriptor = class {
};

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/controller.ts
var import_vscode3 = require("vscode");

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/words.ts
var Words = class {
  static createWordCharacters(wordSeparators) {
    const result = [];
    for (let chCode = 0; chCode < 256; chCode++) {
      result[chCode] = 0 /* REGULAR */;
    }
    for (let i = 0, len = wordSeparators.length; i < len; i++) {
      result[wordSeparators.charCodeAt(i)] = 1 /* WORD_SEPARATOR */;
    }
    result[" ".charCodeAt(0)] = 2 /* WHITESPACE */;
    result["	".charCodeAt(0)] = 2 /* WHITESPACE */;
    return result;
  }
  static findNextWord(doc, pos, wordCharacterClass) {
    const lineContent = doc.lineAt(pos.line).text;
    let wordType = 0 /* NONE */;
    const len = lineContent.length;
    for (let chIndex = pos.character; chIndex < len; chIndex++) {
      const chCode = lineContent.charCodeAt(chIndex);
      const chClass = wordCharacterClass[chCode] || 0 /* REGULAR */;
      if (chClass === 0 /* REGULAR */) {
        if (wordType === 1 /* SEPARATOR */) {
          return this._createWord(lineContent, wordType, this._findStartOfWord(lineContent, wordCharacterClass, wordType, chIndex - 1), chIndex);
        }
        wordType = 2 /* REGULAR */;
      } else if (chClass === 1 /* WORD_SEPARATOR */) {
        if (wordType === 2 /* REGULAR */) {
          return this._createWord(lineContent, wordType, this._findStartOfWord(lineContent, wordCharacterClass, wordType, chIndex - 1), chIndex);
        }
        wordType = 1 /* SEPARATOR */;
      } else if (chClass === 2 /* WHITESPACE */) {
        if (wordType !== 0 /* NONE */) {
          return this._createWord(lineContent, wordType, this._findStartOfWord(lineContent, wordCharacterClass, wordType, chIndex - 1), chIndex);
        }
      }
    }
    if (wordType !== 0 /* NONE */) {
      return this._createWord(lineContent, wordType, this._findStartOfWord(lineContent, wordCharacterClass, wordType, len - 1), len);
    }
    return null;
  }
  static _findStartOfWord(lineContent, wordCharacterClass, wordType, startIndex) {
    for (let chIndex = startIndex; chIndex >= 0; chIndex--) {
      const chCode = lineContent.charCodeAt(chIndex);
      const chClass = wordCharacterClass[chCode] || 0 /* REGULAR */;
      if (chClass === 2 /* WHITESPACE */) {
        return chIndex + 1;
      }
      if (wordType === 2 /* REGULAR */ && chClass === 1 /* WORD_SEPARATOR */) {
        return chIndex + 1;
      }
      if (wordType === 1 /* SEPARATOR */ && chClass === 0 /* REGULAR */) {
        return chIndex + 1;
      }
    }
    return 0;
  }
  static _createWord(lineContent, wordType, start, end) {
    return { start, end, wordType };
  }
};

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/motions.ts
var import_vscode = require("vscode");
var MotionState = class {
  anchor;
  cursorDesiredCharacter;
  wordCharacterClass;
  constructor() {
    this.cursorDesiredCharacter = -1;
    this.wordCharacterClass = null;
    this.anchor = null;
  }
};
var Motion = class {
  repeat(hasRepeatCount, count) {
    if (!hasRepeatCount) {
      return this;
    }
    return new RepeatingMotion(this, count);
  }
};
var RepeatingMotion = class extends Motion {
  _actual;
  _repeatCount;
  constructor(actual, repeatCount) {
    super();
    this._actual = actual;
    this._repeatCount = repeatCount;
  }
  run(doc, pos, state) {
    for (let cnt = 0; cnt < this._repeatCount; cnt++) {
      pos = this._actual.run(doc, pos, state);
    }
    return pos;
  }
};
var NextCharacterMotion = class extends Motion {
  run(doc, pos, _state) {
    if (pos.character === doc.lineAt(pos.line).text.length) {
      return pos.line + 1 < doc.lineCount ? new import_vscode.Position(pos.line + 1, 0) : pos;
    }
    return new import_vscode.Position(pos.line, pos.character + 1);
  }
};
var RightMotion = class extends Motion {
  run(doc, pos, state) {
    const line = pos.line;
    const maxCharacter = doc.lineAt(line).text.length;
    if (pos.character < maxCharacter) {
      state.cursorDesiredCharacter = pos.character + 1;
      return new import_vscode.Position(line, state.cursorDesiredCharacter);
    }
    return pos;
  }
};
var EndOfLineMotion = class extends Motion {
  run(doc, pos, _state) {
    return new import_vscode.Position(pos.line, doc.lineAt(pos.line).text.length);
  }
};
var StartOfLineMotion = class extends Motion {
  run(_doc, pos, _state) {
    return new import_vscode.Position(pos.line, 0);
  }
};
var NextWordStartMotion = class extends Motion {
  run(doc, pos, state) {
    const lineContent = doc.lineAt(pos.line).text;
    if (pos.character >= lineContent.length - 1) {
      return pos.line + 1 < doc.lineCount ? new import_vscode.Position(pos.line + 1, 0) : pos;
    }
    const nextWord = Words.findNextWord(doc, pos, state.wordCharacterClass);
    if (!nextWord) {
      return Motions.EndOfLine.run(doc, pos, state);
    }
    if (nextWord.start <= pos.character && pos.character < nextWord.end) {
      const nextNextWord = Words.findNextWord(doc, new import_vscode.Position(pos.line, nextWord.end), state.wordCharacterClass);
      if (nextNextWord) {
        return new import_vscode.Position(pos.line, nextNextWord.start);
      } else {
        return Motions.EndOfLine.run(doc, pos, state);
      }
    } else {
      return new import_vscode.Position(pos.line, nextWord.start);
    }
  }
};
var NextWordEndMotion = class extends Motion {
  run(doc, pos, state) {
    const lineContent = doc.lineAt(pos.line).text;
    if (pos.character >= lineContent.length - 1) {
      return pos.line + 1 < doc.lineCount ? new import_vscode.Position(pos.line + 1, 0) : pos;
    }
    const nextWord = Words.findNextWord(doc, pos, state.wordCharacterClass);
    if (!nextWord) {
      return Motions.EndOfLine.run(doc, pos, state);
    }
    return new import_vscode.Position(pos.line, nextWord.end);
  }
};
var GoToLineUndefinedMotion = class extends Motion {
  run(_doc, pos, _state) {
    return pos;
  }
  repeat(hasRepeatCount, count) {
    if (!hasRepeatCount) {
      return Motions.GoToLastLine;
    }
    return new GoToLineDefinedMotion(count);
  }
};
var GoToLineMotion = class extends Motion {
  firstNonWhitespaceChar(doc, line) {
    const lineContent = doc.lineAt(line).text;
    let character = 0;
    while (character < lineContent.length) {
      const ch = lineContent.charAt(character);
      if (ch !== " " && ch !== "	") {
        break;
      }
      character++;
    }
    return character;
  }
};
var GoToFirstLineMotion = class extends GoToLineMotion {
  run(doc, _pos, _state) {
    return new import_vscode.Position(0, this.firstNonWhitespaceChar(doc, 0));
  }
};
var GoToLastLineMotion = class extends GoToLineMotion {
  run(doc, _pos, _state) {
    const lastLine = doc.lineCount - 1;
    return new import_vscode.Position(lastLine, this.firstNonWhitespaceChar(doc, lastLine));
  }
};
var GoToLineDefinedMotion = class extends GoToLineMotion {
  _lineNumber;
  constructor(lineNumber) {
    super();
    this._lineNumber = lineNumber;
  }
  run(doc, _pos, _state) {
    const line = Math.min(doc.lineCount - 1, Math.max(0, this._lineNumber - 1));
    return new import_vscode.Position(line, this.firstNonWhitespaceChar(doc, line));
  }
};
var CursorMoveCommand = class extends AbstractCommandDescriptor {
  constructor(to, by) {
    super();
    this.to = to;
    this.by = by;
  }
  createCommand(args) {
    const cursorMoveArgs = {
      to: this.to,
      by: this.by,
      value: args.repeat || 1,
      select: !!args.isVisual
    };
    return {
      commandId: "cursorMove",
      args: cursorMoveArgs
    };
  }
};
var EditorScrollCommand = class extends AbstractCommandDescriptor {
  constructor(to, by) {
    super();
    this.to = to;
    this.by = by;
  }
  createCommand(args) {
    const editorScrollArgs = {
      to: this.to,
      by: this.by,
      value: args.repeat || 1,
      revealCursor: true
    };
    return {
      commandId: "editorScroll",
      args: editorScrollArgs
    };
  }
};
var RevealCurrentLineCommand = class extends AbstractCommandDescriptor {
  constructor(at) {
    super();
    this.at = at;
  }
  createCommand(_args) {
    const lineNumber = import_vscode.window.activeTextEditor.selection.start.line;
    const revealLineArgs = {
      lineNumber,
      at: this.at
    };
    return {
      commandId: "revealLine",
      args: revealLineArgs
    };
  }
};
var MoveActiveEditorCommandByPosition = class extends AbstractCommandDescriptor {
  constructor() {
    super();
  }
  createCommand(args) {
    const moveActiveEditorArgs = {
      to: args.repeat === void 0 ? "last" : "position",
      value: args.repeat !== void 0 ? args.repeat + 1 : void 0
    };
    return {
      commandId: "moveActiveEditor",
      args: moveActiveEditorArgs
    };
  }
};
var MoveActiveEditorCommand = class extends AbstractCommandDescriptor {
  constructor(to) {
    super();
    this.to = to;
  }
  createCommand(args) {
    const moveActiveEditorArgs = {
      to: this.to,
      value: args.repeat ? args.repeat : 1
    };
    return {
      commandId: "moveActiveEditor",
      args: moveActiveEditorArgs
    };
  }
};
var FoldCommand = class extends AbstractCommandDescriptor {
  constructor() {
    super();
  }
  createCommand(args) {
    const foldEditorArgs = {
      levels: args.repeat ? args.repeat : 1,
      direction: "up"
    };
    return {
      commandId: "editor.fold",
      args: foldEditorArgs
    };
  }
};
var UnfoldCommand = class extends AbstractCommandDescriptor {
  constructor() {
    super();
  }
  createCommand(args) {
    const foldEditorArgs = {
      levels: args.repeat ? args.repeat : 1,
      direction: "up"
    };
    return {
      commandId: "editor.unfold",
      args: foldEditorArgs
    };
  }
};
var Motions = {
  RightMotion: new RightMotion(),
  NextCharacter: new NextCharacterMotion(),
  Left: new CursorMoveCommand("left"),
  Right: new CursorMoveCommand("right"),
  Down: new CursorMoveCommand("down"),
  Up: new CursorMoveCommand("up"),
  EndOfLine: new EndOfLineMotion(),
  StartOfLine: new StartOfLineMotion(),
  NextWordStart: new NextWordStartMotion(),
  NextWordEnd: new NextWordEndMotion(),
  GoToLine: new GoToLineUndefinedMotion(),
  GoToFirstLine: new GoToFirstLineMotion(),
  GoToLastLine: new GoToLastLineMotion(),
  CursorScrollLeft: new CursorMoveCommand("left"),
  CursorScrollRight: new CursorMoveCommand("right"),
  CursorScrollLeftByHalfLine: new CursorMoveCommand("left", "halfLine"),
  CursorScrollRightByHalfLine: new CursorMoveCommand("right", "halfLine"),
  WrappedLineUp: new CursorMoveCommand("up", "wrappedLine"),
  WrappedLineDown: new CursorMoveCommand("down", "wrappedLine"),
  WrappedLineStart: new CursorMoveCommand("wrappedLineStart"),
  WrappedLineFirstNonWhiteSpaceCharacter: new CursorMoveCommand("wrappedLineFirstNonWhitespaceCharacter"),
  WrappedLineColumnCenter: new CursorMoveCommand("wrappedLineColumnCenter"),
  WrappedLineEnd: new CursorMoveCommand("wrappedLineEnd"),
  WrappedLineLastNonWhiteSpaceCharacter: new CursorMoveCommand("wrappedLineLastNonWhitespaceCharacter"),
  ViewPortTop: new CursorMoveCommand("viewPortTop"),
  ViewPortBottom: new CursorMoveCommand("viewPortBottom"),
  ViewPortCenter: new CursorMoveCommand("viewPortCenter"),
  MoveActiveEditor: new MoveActiveEditorCommandByPosition(),
  MoveActiveEditorLeft: new MoveActiveEditorCommand("left"),
  MoveActiveEditorRight: new MoveActiveEditorCommand("right"),
  MoveActiveEditorFirst: new MoveActiveEditorCommand("first"),
  MoveActiveEditorLast: new MoveActiveEditorCommand("last"),
  MoveActiveEditorCenter: new MoveActiveEditorCommand("center"),
  ScrollDownByLine: new EditorScrollCommand("down", "line"),
  ScrollDownByHalfPage: new EditorScrollCommand("down", "halfPage"),
  ScrollDownByPage: new EditorScrollCommand("down", "page"),
  ScrollUpByLine: new EditorScrollCommand("up", "line"),
  ScrollUpByHalfPage: new EditorScrollCommand("up", "halfPage"),
  ScrollUpByPage: new EditorScrollCommand("up", "page"),
  RevealCurrentLineAtTop: new RevealCurrentLineCommand("top"),
  RevealCurrentLineAtCenter: new RevealCurrentLineCommand("center"),
  RevealCurrentLineAtBottom: new RevealCurrentLineCommand("bottom"),
  FoldUnder: new FoldCommand(),
  UnfoldUnder: new UnfoldCommand()
};

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/operators.ts
var import_vscode2 = require("vscode");
var Operator = class {
  doc(ed) {
    return ed.document;
  }
  pos(ed) {
    return ed.selection.active;
  }
  sel(ed) {
    return ed.selection;
  }
  setPosReveal(ed, line, char) {
    ed.selection = new import_vscode2.Selection(new import_vscode2.Position(line, char), new import_vscode2.Position(line, char));
    ed.revealRange(ed.selection, import_vscode2.TextEditorRevealType.Default);
  }
  delete(ctrl, ed, isWholeLine, range) {
    ctrl.setDeleteRegister(new DeleteRegister(isWholeLine, ed.document.getText(range)));
    ed.edit((builder) => {
      builder.delete(range);
    });
  }
};
var OperatorWithNoArgs = class extends Operator {
  runNormalMode(ctrl, ed, _repeatCount, _args) {
    this._run(ctrl, ed);
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    this._run(ctrl, ed);
    return true;
  }
};
var InsertOperator = class extends OperatorWithNoArgs {
  _run(ctrl, _ed) {
    ctrl.setMode(0 /* INSERT */);
  }
};
var AppendOperator = class extends OperatorWithNoArgs {
  _run(ctrl, ed) {
    const newPos = Motions.RightMotion.run(this.doc(ed), this.pos(ed), ctrl.motionState);
    this.setPosReveal(ed, newPos.line, newPos.character);
    ctrl.setMode(0 /* INSERT */);
  }
};
var AppendEndOfLineOperator = class extends OperatorWithNoArgs {
  _run(ctrl, ed) {
    const newPos = Motions.EndOfLine.run(this.doc(ed), this.pos(ed), ctrl.motionState);
    this.setPosReveal(ed, newPos.line, newPos.character);
    ctrl.setMode(0 /* INSERT */);
  }
};
var VisualOperator = class extends OperatorWithNoArgs {
  _run(ctrl, ed) {
    ctrl.motionState.anchor = this.pos(ed);
    ctrl.setVisual(true);
  }
};
var DeleteCharUnderCursorOperator = class extends Operator {
  runNormalMode(ctrl, ed, repeatCount, _args) {
    const to = Motions.NextCharacter.repeat(repeatCount > 1, repeatCount).run(this.doc(ed), this.pos(ed), ctrl.motionState);
    const from = this.pos(ed);
    this.delete(ctrl, ed, false, new import_vscode2.Range(from.line, from.character, to.line, to.character));
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    const sel = this.sel(ed);
    this.delete(ctrl, ed, false, sel);
    return true;
  }
};
var DeleteLineOperator = class extends Operator {
  runNormalMode(ctrl, ed, repeatCount, _args) {
    const pos = this.pos(ed);
    const doc = this.doc(ed);
    let fromLine = pos.line;
    let fromCharacter = 0;
    let toLine = fromLine + repeatCount;
    let toCharacter = 0;
    if (toLine >= doc.lineCount - 1) {
      toLine = doc.lineCount - 1;
      toCharacter = doc.lineAt(toLine).text.length;
      if (fromLine > 0) {
        fromLine = fromLine - 1;
        fromCharacter = doc.lineAt(fromLine).text.length;
      }
    }
    this.delete(ctrl, ed, true, new import_vscode2.Range(fromLine, fromCharacter, toLine, toCharacter));
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    const sel = this.sel(ed);
    this.delete(ctrl, ed, false, sel);
    return true;
  }
};
var OperatorWithMotion = class extends Operator {
  runNormalMode(ctrl, ed, repeatCount, args) {
    const motion = ctrl.findMotion(args);
    if (!motion) {
      if (ctrl.isMotionPrefix(args)) {
        return false;
      }
      return true;
    }
    return this._runNormalMode(ctrl, ed, motion.repeat(repeatCount > 1, repeatCount));
  }
};
var DeleteToOperator = class extends OperatorWithMotion {
  runNormalMode(ctrl, ed, repeatCount, args) {
    if (args === "d") {
      return Operators.DeleteLine.runNormalMode(ctrl, ed, repeatCount, args);
    }
    return super.runNormalMode(ctrl, ed, repeatCount, args);
  }
  _runNormalMode(ctrl, ed, motion) {
    const to = motion.run(this.doc(ed), this.pos(ed), ctrl.motionState);
    const from = this.pos(ed);
    this.delete(ctrl, ed, false, new import_vscode2.Range(from.line, from.character, to.line, to.character));
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    const sel = this.sel(ed);
    this.delete(ctrl, ed, false, sel);
    return true;
  }
};
var PutOperator = class extends Operator {
  runNormalMode(ctrl, ed, repeatCount, _args) {
    const register = ctrl.getDeleteRegister();
    if (!register) {
      return true;
    }
    let str = repeatString(register.content, repeatCount);
    const pos = this.pos(ed);
    if (!register.isWholeLine) {
      ed.edit((builder) => {
        builder.insert(new import_vscode2.Position(pos.line, pos.character + 1), str);
      });
      return true;
    }
    const doc = this.doc(ed);
    let insertLine = pos.line + 1;
    let insertCharacter = 0;
    if (insertLine >= doc.lineCount) {
      insertLine = doc.lineCount - 1;
      insertCharacter = doc.lineAt(insertLine).text.length;
      str = "\n" + str;
    }
    ed.edit((builder) => {
      builder.insert(new import_vscode2.Position(insertLine, insertCharacter), str);
    });
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    const register = ctrl.getDeleteRegister();
    if (!register) {
      return false;
    }
    const str = register.content;
    const sel = this.sel(ed);
    ed.edit((builder) => {
      builder.replace(sel, str);
    });
    return true;
  }
};
var ReplaceOperator = class extends Operator {
  runNormalMode(_ctrl, ed, repeatCount, args) {
    if (args.length === 0) {
      return false;
    }
    const doc = this.doc(ed);
    const pos = this.pos(ed);
    const toCharacter = pos.character + repeatCount;
    if (toCharacter > doc.lineAt(pos).text.length) {
      return true;
    }
    ed.edit((builder) => {
      builder.replace(new import_vscode2.Range(pos.line, pos.character, pos.line, toCharacter), repeatString(args, repeatCount));
    });
    return true;
  }
  runVisualMode(_ctrl, ed, args) {
    if (args.length === 0) {
      return false;
    }
    const doc = this.doc(ed);
    const sel = this.sel(ed);
    const srcString = doc.getText(sel);
    let dstString = "";
    for (let i = 0; i < srcString.length; i++) {
      const ch = srcString.charAt(i);
      if (ch === "\r" || ch === "\n") {
        dstString += ch;
      } else {
        dstString += args;
      }
    }
    ed.edit((builder) => {
      builder.replace(sel, dstString);
    });
    return true;
  }
};
var ReplaceModeOperator = class extends Operator {
  runNormalMode(ctrl, _ed, _repeatCount, _args) {
    ctrl.setMode(2 /* REPLACE */);
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    this.delete(ctrl, ed, false, this.sel(ed));
    ctrl.setMode(0 /* INSERT */);
    return true;
  }
};
var ChangeOperator = class extends OperatorWithMotion {
  _runNormalMode(ctrl, ed, motion) {
    const to = motion.run(this.doc(ed), this.pos(ed), ctrl.motionState);
    const from = this.pos(ed);
    this.delete(ctrl, ed, false, new import_vscode2.Range(from.line, from.character, to.line, to.character));
    ctrl.setMode(0 /* INSERT */);
    return true;
  }
  runVisualMode(ctrl, ed, _args) {
    const sel = this.sel(ed);
    this.delete(ctrl, ed, false, sel);
    ctrl.setMode(0 /* INSERT */);
    return true;
  }
};
function repeatString(str, repeatCount) {
  let result = "";
  for (let i = 0; i < repeatCount; i++) {
    result += str;
  }
  return result;
}
var Operators = {
  Insert: new InsertOperator(),
  Visual: new VisualOperator(),
  Append: new AppendOperator(),
  AppendEndOfLine: new AppendEndOfLineOperator(),
  DeleteCharUnderCursor: new DeleteCharUnderCursorOperator(),
  DeleteTo: new DeleteToOperator(),
  DeleteLine: new DeleteLineOperator(),
  Put: new PutOperator(),
  Replace: new ReplaceOperator(),
  Change: new ChangeOperator(),
  ReplaceMode: new ReplaceModeOperator()
};

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/mappings.ts
var CHAR_TO_BINDING = {};
function defineBinding(char, value, modifierKeys) {
  const key = modifierKeys.ctrl ? "CTRL + " + char : char;
  CHAR_TO_BINDING[key] = value;
}
function getBinding(char, modifierKeys) {
  const key = modifierKeys.ctrl ? "CTRL + " + char : char;
  return CHAR_TO_BINDING[key];
}
function defineOperator(char, operator, modifierKeys = {}) {
  defineBinding(char + "__operator__", operator, modifierKeys);
}
function getOperator(char, modifierKeys = {}) {
  return getBinding(char + "__operator__", modifierKeys);
}
function defineCommand(char, commandId, modifierKeys = {}) {
  defineBinding(char + "__command__", { commandId }, modifierKeys);
}
function getCommand(char, modifierKeys = {}) {
  return getBinding(char + "__command__", modifierKeys);
}
function defineMotion(char, motion, modifierKeys = {}) {
  defineBinding(char + "__motion__", motion, modifierKeys);
}
function getMotion(char, modifierKeys = {}) {
  return getBinding(char + "__motion__", modifierKeys);
}
function defineMotionCommand(char, motionCommand, modifierKeys = {}) {
  defineBinding(char + "__motioncommand__", motionCommand, modifierKeys);
}
function getMotionCommand(char, modifierKeys = {}) {
  return getBinding(char + "__motioncommand__", modifierKeys);
}
defineOperator("x", Operators.DeleteCharUnderCursor);
defineOperator("i", Operators.Insert);
defineOperator("a", Operators.Append);
defineOperator("A", Operators.AppendEndOfLine);
defineOperator("d", Operators.DeleteTo);
defineOperator("p", Operators.Put);
defineOperator("r", Operators.Replace);
defineOperator("R", Operators.ReplaceMode);
defineOperator("c", Operators.Change);
defineOperator("v", Operators.Visual);
defineCommand("u", "undo");
defineCommand("U", "undo");
defineMotionCommand("h", Motions.Left);
defineMotionCommand("l", Motions.Right);
defineMotion("0", Motions.StartOfLine);
defineMotion("$", Motions.EndOfLine);
defineMotionCommand("g0", Motions.WrappedLineStart);
defineMotionCommand("g^", Motions.WrappedLineFirstNonWhiteSpaceCharacter);
defineMotionCommand("gm", Motions.WrappedLineColumnCenter);
defineMotionCommand("g$", Motions.WrappedLineEnd);
defineMotionCommand("g_", Motions.WrappedLineLastNonWhiteSpaceCharacter);
defineMotionCommand("zh", Motions.CursorScrollLeft);
defineMotionCommand("zl", Motions.CursorScrollRight);
defineMotionCommand("zH", Motions.CursorScrollLeftByHalfLine);
defineMotionCommand("zL", Motions.CursorScrollRightByHalfLine);
defineMotionCommand("j", Motions.Down);
defineMotionCommand("k", Motions.Up);
defineMotionCommand("gj", Motions.WrappedLineDown);
defineMotionCommand("gk", Motions.WrappedLineUp);
defineMotion("G", Motions.GoToLine);
defineMotion("gg", Motions.GoToFirstLine);
defineMotionCommand("H", Motions.ViewPortTop);
defineMotionCommand("M", Motions.ViewPortCenter);
defineMotionCommand("L", Motions.ViewPortBottom);
defineMotion("w", Motions.NextWordStart);
defineMotion("e", Motions.NextWordEnd);
defineMotionCommand("tabm", Motions.MoveActiveEditor);
defineMotionCommand("tabm<", Motions.MoveActiveEditorLeft);
defineMotionCommand("tabm>", Motions.MoveActiveEditorRight);
defineMotionCommand("tabm<<", Motions.MoveActiveEditorFirst);
defineMotionCommand("tabm>>", Motions.MoveActiveEditorLast);
defineMotionCommand("tabm.", Motions.MoveActiveEditorCenter);
defineMotionCommand("e", Motions.ScrollDownByLine, { ctrl: true });
defineMotionCommand("d", Motions.ScrollDownByHalfPage, { ctrl: true });
defineMotionCommand("f", Motions.ScrollDownByPage, { ctrl: true });
defineMotionCommand("y", Motions.ScrollUpByLine, { ctrl: true });
defineMotionCommand("u", Motions.ScrollUpByHalfPage, { ctrl: true });
defineMotionCommand("b", Motions.ScrollUpByPage, { ctrl: true });
defineMotionCommand("zt", Motions.RevealCurrentLineAtTop);
defineMotionCommand("zz", Motions.RevealCurrentLineAtCenter);
defineMotionCommand("zb", Motions.RevealCurrentLineAtBottom);
defineMotionCommand("zc", Motions.FoldUnder);
defineMotionCommand("zo", Motions.UnfoldUnder);
var Mappings = class _Mappings {
  static findMotion(input) {
    const parsed = _parseNumberAndString(input);
    let motion = getMotion(parsed.input.substr(0, 1));
    if (!motion) {
      motion = getMotion(parsed.input.substr(0, 2));
      if (!motion) {
        return null;
      }
    }
    return motion.repeat(parsed.hasRepeatCount, parsed.repeatCount);
  }
  static findMotionCommand(input, isVisual, modifierKeys) {
    let parsed = _parseNumberAndString(input);
    let command = _Mappings.findMotionCommandFromNumberAndString(parsed, isVisual, modifierKeys);
    if (!command) {
      parsed = _parseNumberAndString(input, false);
      command = _Mappings.findMotionCommandFromNumberAndString(parsed, isVisual, modifierKeys);
    }
    return command;
  }
  static findMotionCommandFromNumberAndString(numberAndString, isVisual, modifierKeys) {
    let motionCommand = getMotionCommand(numberAndString.input.substr(0, 1), modifierKeys);
    if (!motionCommand) {
      motionCommand = getMotionCommand(numberAndString.input.substr(0, 2), modifierKeys);
    }
    if (!motionCommand) {
      motionCommand = getMotionCommand(numberAndString.input.substr(1, 2), modifierKeys);
    }
    if (!motionCommand) {
      motionCommand = getMotionCommand(numberAndString.input.substr(1, 3), modifierKeys);
    }
    if (!motionCommand) {
      motionCommand = getMotionCommand(numberAndString.input, modifierKeys);
    }
    return motionCommand ? motionCommand.createCommand({ isVisual, repeat: numberAndString.hasRepeatCount ? numberAndString.repeatCount : void 0 }) : null;
  }
  static findOperator(input, modifierKeys) {
    const parsed = _parseNumberAndString(input);
    const operator = getOperator(parsed.input.substr(0, 1), modifierKeys);
    if (!operator) {
      return null;
    }
    const operatorArgs = parsed.input.substr(1);
    return {
      runNormal: (controller, editor) => {
        return operator.runNormalMode(controller, editor, parsed.repeatCount, operatorArgs);
      },
      runVisual: (controller, editor) => {
        return operator.runVisualMode(controller, editor, operatorArgs);
      }
    };
  }
  static findCommand(input, modifierKeys) {
    return getCommand(input, modifierKeys) || null;
  }
  static isMotionPrefix(input) {
    if (input.length === 0) {
      return true;
    }
    if (input === "g" || input === "v" || input === "z") {
      return true;
    }
    return /^[1-9]\d*v?g?z?$/.test(input);
  }
};
function _parseNumberAndString(input, numberAtBeginning = true) {
  if (numberAtBeginning) {
    const repeatCountMatch = input.match(/^([1-9]\d*)/);
    if (repeatCountMatch) {
      return {
        hasRepeatCount: true,
        repeatCount: parseInt(repeatCountMatch[0], 10),
        input: input.substr(repeatCountMatch[0].length)
      };
    }
  } else {
    const repeatCountMatch = input.match(/(\d+)$/);
    if (repeatCountMatch) {
      return {
        hasRepeatCount: true,
        repeatCount: parseInt(repeatCountMatch[1], 10),
        input: input.substr(0, input.length - repeatCountMatch[1].length)
      };
    }
  }
  return {
    hasRepeatCount: false,
    repeatCount: 1,
    input
  };
}

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/controller.ts
var Controller = class {
  _currentMode;
  _currentInput;
  _motionState;
  _isVisual;
  get motionState() {
    return this._motionState;
  }
  findMotion(input) {
    return Mappings.findMotion(input);
  }
  isMotionPrefix(input) {
    return Mappings.isMotionPrefix(input);
  }
  _deleteRegister;
  setDeleteRegister(register) {
    this._deleteRegister = register;
  }
  getDeleteRegister() {
    return this._deleteRegister;
  }
  constructor() {
    this._motionState = new MotionState();
    this._deleteRegister = null;
    this.setVisual(false);
    this.setMode(1 /* NORMAL */);
  }
  setWordSeparators(wordSeparators) {
    this._motionState.wordCharacterClass = Words.createWordCharacters(wordSeparators);
  }
  ensureNormalModePosition(editor) {
    if (this._currentMode !== 1 /* NORMAL */) {
      return;
    }
    if (this._isVisual) {
      return;
    }
    const sel = editor.selection;
    const pos = sel.active;
    const doc = editor.document;
    const lineContent = doc.lineAt(pos.line).text;
    if (lineContent.length === 0) {
      return;
    }
    const maxCharacter = lineContent.length - 1;
    if (pos.character > maxCharacter) {
      setPositionAndReveal(editor, pos.line, maxCharacter);
    }
  }
  hasInput() {
    return this._currentInput.length > 0;
  }
  clearInput() {
    this._currentInput = "";
  }
  getMode() {
    return this._currentMode;
  }
  setMode(newMode) {
    if (newMode !== this._currentMode) {
      this._currentMode = newMode;
      this._motionState.cursorDesiredCharacter = -1;
      this._currentInput = "";
    }
  }
  setVisual(newVisual) {
    if (this._isVisual !== newVisual) {
      this._isVisual = newVisual;
    }
  }
  getVisual() {
    return this._isVisual;
  }
  getCursorStyle() {
    if (this._currentMode === 1 /* NORMAL */) {
      if (/^([1-9]\d*)?(r|c)/.test(this._currentInput)) {
        return import_vscode3.TextEditorCursorStyle.Underline;
      }
      return import_vscode3.TextEditorCursorStyle.Block;
    }
    if (this._currentMode === 2 /* REPLACE */) {
      return import_vscode3.TextEditorCursorStyle.Underline;
    }
    return import_vscode3.TextEditorCursorStyle.Line;
  }
  _getModeLabel() {
    if (this._currentMode === 1 /* NORMAL */) {
      if (this._isVisual) {
        return "-- VISUAL --";
      }
      return "-- NORMAL --";
    }
    if (this._currentMode === 2 /* REPLACE */) {
      if (this._isVisual) {
        return "-- (replace) VISUAL --";
      }
      return "-- REPLACE --";
    }
    if (this._isVisual) {
      return "-- (insert) VISUAL --";
    }
    return "-- INSERT --";
  }
  getStatusText() {
    const label = this._getModeLabel();
    return `VIM:> ${label}` + (this._currentInput ? ` >${this._currentInput}` : ``);
  }
  _isInComposition = false;
  _composingText = "";
  compositionStart(_editor) {
    this._isInComposition = true;
    this._composingText = "";
  }
  compositionEnd(editor) {
    this._isInComposition = false;
    const text = this._composingText;
    this._composingText = "";
    if (text.length === 0) {
      return Promise.resolve({
        hasConsumedInput: true,
        executeEditorCommand: null
      });
    }
    return this.type(editor, text, {});
  }
  type(editor, text, modifierKeys) {
    if (this._currentMode !== 1 /* NORMAL */ && this._currentMode !== 2 /* REPLACE */) {
      return Promise.resolve({
        hasConsumedInput: false,
        executeEditorCommand: null
      });
    }
    if (this._isInComposition) {
      this._composingText += text;
      return Promise.resolve({
        hasConsumedInput: true,
        executeEditorCommand: null
      });
    }
    if (this._currentMode === 2 /* REPLACE */) {
      const pos = editor.selection.active;
      editor.edit((builder) => {
        builder.replace(new import_vscode3.Range(pos.line, pos.character, pos.line, pos.character + 1), text);
      }).then(() => {
        setPositionAndReveal(editor, pos.line, pos.character + 1);
      });
      return Promise.resolve({
        hasConsumedInput: true,
        executeEditorCommand: null
      });
    }
    this._currentInput += text;
    return this._interpretNormalModeInput(editor, modifierKeys);
  }
  replacePrevChar(editor, text, replaceCharCnt) {
    if (this._currentMode !== 1 /* NORMAL */ && this._currentMode !== 2 /* REPLACE */) {
      return false;
    }
    if (this._isInComposition) {
      this._composingText = this._composingText.substr(0, this._composingText.length - replaceCharCnt) + text;
      return true;
    }
    if (this._currentMode === 2 /* REPLACE */) {
      const pos = editor.selection.active;
      editor.edit((builder) => {
        builder.replace(new import_vscode3.Range(pos.line, pos.character - replaceCharCnt, pos.line, pos.character), text);
      });
      return true;
    }
    return true;
  }
  _interpretNormalModeInput(editor, modifierKeys) {
    if (this._currentInput.startsWith(":")) {
      return import_vscode3.window.showInputBox({ value: "tabm" }).then((value) => {
        return this._findMapping(value || "", editor, modifierKeys);
      });
    }
    const result = this._findMapping(this._currentInput, editor, modifierKeys);
    return Promise.resolve(result);
  }
  _findMapping(input, editor, modifierKeys) {
    const command = Mappings.findCommand(input, modifierKeys);
    if (command) {
      this._currentInput = "";
      return {
        hasConsumedInput: true,
        executeEditorCommand: command
      };
    }
    const operator = Mappings.findOperator(input, modifierKeys);
    if (operator) {
      if (this._isVisual) {
        if (operator.runVisual(this, editor)) {
          this._currentInput = "";
        }
      } else {
        if (operator.runNormal(this, editor)) {
          this._currentInput = "";
        }
      }
      return {
        hasConsumedInput: true,
        executeEditorCommand: null
      };
    }
    const motionCommand = Mappings.findMotionCommand(input, this._isVisual, modifierKeys);
    if (motionCommand) {
      this._currentInput = "";
      return {
        hasConsumedInput: true,
        executeEditorCommand: motionCommand
      };
    }
    const motion = Mappings.findMotion(input);
    if (motion) {
      const newPos = motion.run(editor.document, editor.selection.active, this._motionState);
      if (this._isVisual) {
        setSelectionAndReveal(editor, this._motionState.anchor, newPos.line, newPos.character);
      } else {
        setPositionAndReveal(editor, newPos.line, newPos.character);
      }
      this._currentInput = "";
      return {
        hasConsumedInput: true,
        executeEditorCommand: null
      };
    }
    if (this.isMotionPrefix(input)) {
      return {
        hasConsumedInput: true,
        executeEditorCommand: null
      };
    }
    this._currentInput = "";
    return {
      hasConsumedInput: true,
      executeEditorCommand: null
    };
  }
};
function setSelectionAndReveal(editor, anchor, line, char) {
  editor.selection = new import_vscode3.Selection(anchor, new import_vscode3.Position(line, char));
  revealPosition(editor, line, char);
}
function setPositionAndReveal(editor, line, char) {
  editor.selection = new import_vscode3.Selection(new import_vscode3.Position(line, char), new import_vscode3.Position(line, char));
  revealPosition(editor, line, char);
}
function revealPosition(editor, line, char) {
  editor.revealRange(new import_vscode3.Range(line, char, line, char), import_vscode3.TextEditorRevealType.Default);
}

// .codex/skills/moonbit-vscode-samples/references/vscode-extension-samples/vim-sample/src/extension.ts
function activate(context) {
  function registerCommandNice(commandId, run) {
    context.subscriptions.push(vscode.commands.registerCommand(commandId, run));
  }
  function registerCtrlKeyBinding(key) {
    registerCommandNice(key, function() {
      if (!vscode.window.activeTextEditor) {
        return;
      }
      vimExt.type(key, { ctrl: true });
    });
  }
  const vimExt = new VimExt();
  registerCommandNice("type", function(args) {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    vimExt.type(args.text);
  });
  registerCommandNice("replacePreviousChar", function(args) {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    vimExt.replacePrevChar(args.text, args.replaceCharCnt);
  });
  registerCommandNice("compositionStart", function() {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    vimExt.compositionStart();
  });
  registerCommandNice("compositionEnd", function() {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    vimExt.compositionEnd();
  });
  registerCommandNice("vim.goToNormalMode", function() {
    vimExt.goToNormalMode();
  });
  registerCommandNice("vim.clearInput", function() {
    vimExt.clearInput();
  });
  registerCtrlKeyBinding("e");
  registerCtrlKeyBinding("d");
  registerCtrlKeyBinding("f");
  registerCtrlKeyBinding("y");
  registerCtrlKeyBinding("u");
  registerCtrlKeyBinding("b");
}
function deactivate() {
}
function getConfiguredWordSeparators() {
  const editorConfig = vscode.workspace.getConfiguration("editor");
  return editorConfig["wordSeparators"];
}
var VimExt = class {
  _inNormalMode;
  _hasInput;
  _statusBar;
  _controller;
  constructor() {
    this._inNormalMode = new ContextKey("vim.inNormalMode");
    this._hasInput = new ContextKey("vim.hasInput");
    this._statusBar = new StatusBar();
    this._controller = new Controller();
    vscode.window.onDidChangeActiveTextEditor((textEditor) => {
      if (!textEditor) {
        return;
      }
      this._ensureState();
    });
    vscode.window.onDidChangeTextEditorSelection((e) => {
      const isVisual = this._controller.getVisual();
      if (!isVisual) {
        let goToVisualMode = false;
        if (e.selections.length > 1) {
          goToVisualMode = true;
        } else {
          goToVisualMode = !e.selections[0].isEmpty;
        }
        if (goToVisualMode) {
          this._controller.setVisual(true);
        }
      } else {
        let leaveVisualMode = false;
        if (e.selections.length === 1) {
          leaveVisualMode = e.selections[0].isEmpty;
        }
        if (leaveVisualMode) {
          this._controller.setVisual(false);
        }
      }
      this._ensureState();
    });
    const ensureConfig = () => {
      this._controller.setWordSeparators(getConfiguredWordSeparators());
    };
    ensureConfig();
    vscode.workspace.onDidChangeConfiguration(ensureConfig);
    this._ensureState();
  }
  goToNormalMode() {
    this._controller.setMode(1 /* NORMAL */);
    this._ensureState();
  }
  clearInput() {
    this._controller.clearInput();
    this._ensureState();
  }
  type(text, modifierKeys = { ctrl: false, shifit: false, alt: false }) {
    this._controller.type(vscode.window.activeTextEditor, text, modifierKeys).then((r) => {
      if (r.hasConsumedInput) {
        this._ensureState();
        if (r.executeEditorCommand) {
          let args = [r.executeEditorCommand.commandId];
          args = args.concat(r.executeEditorCommand.args);
          vscode.commands.executeCommand.apply(this, args);
        }
        return;
      }
      vscode.commands.executeCommand("default:type", {
        text
      });
    });
  }
  replacePrevChar(text, replaceCharCnt) {
    if (this._controller.replacePrevChar(vscode.window.activeTextEditor, text, replaceCharCnt)) {
      this._ensureState();
      return;
    }
    vscode.commands.executeCommand("default:replacePreviousChar", {
      text,
      replaceCharCnt
    });
  }
  compositionStart() {
    this._controller.compositionStart(vscode.window.activeTextEditor);
  }
  compositionEnd() {
    this._controller.compositionEnd(vscode.window.activeTextEditor).then((r) => {
      if (r.hasConsumedInput) {
        this._ensureState();
        if (r.executeEditorCommand) {
          let args = [r.executeEditorCommand.commandId];
          args = args.concat(r.executeEditorCommand.args);
          vscode.commands.executeCommand.apply(this, args);
        }
      }
    });
  }
  _ensureState() {
    this._ensurePosition();
    this._statusBar.setText(this._controller.getStatusText());
    this._ensureCursorStyle(this._controller.getCursorStyle());
    this._inNormalMode.set(this._controller.getMode() === 1 /* NORMAL */);
    this._hasInput.set(this._controller.hasInput());
  }
  _ensurePosition() {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    this._controller.ensureNormalModePosition(vscode.window.activeTextEditor);
  }
  _ensureCursorStyle(cursorStyle) {
    if (!vscode.window.activeTextEditor) {
      return;
    }
    const currentCursorStyle = vscode.window.activeTextEditor.options.cursorStyle;
    if (currentCursorStyle !== cursorStyle) {
      vscode.window.activeTextEditor.options = {
        cursorStyle
      };
    }
  }
};
var ContextKey = class {
  _name;
  _lastValue;
  constructor(name) {
    this._name = name;
  }
  set(value) {
    if (this._lastValue === value) {
      return;
    }
    this._lastValue = value;
    vscode.commands.executeCommand("setContext", this._name, this._lastValue);
  }
};
var StatusBar = class {
  _actual;
  _lastText;
  constructor() {
    this._actual = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
    this._actual.show();
  }
  setText(text) {
    if (this._lastText === text) {
      return;
    }
    this._lastText = text;
    this._actual.text = this._lastText;
  }
};
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate,
  deactivate
});
