const std = @import("std");
// Use CameCase in TokenNum because 'var' is keyword in zig
const Feeder = @import("root/feeder/SliceFeeder.zig").SliceFeeder(u8);

const Position = struct {
    line_no: u32,
    char_no: u32,
    fn init(line_no: u32, char_no: u32) Position {
        return Position{
            .line_no = line_no,
            .char_no = char_no,
        };
    }
};

const PunctuationTokenTag = enum {
    // 2 characters
    // Compare
    Ne,
    Ge,
    Le,
    // Definition
    Define,

    // 1 character
    // Punctuations
    LParenthes,
    RParenthes,
    LBracket,
    RBracket,
    LBrace,
    RBrace,
    Comma,
    Colon,
    SemiColon,
    Period,
    // Arithmetic
    Plus,
    Minus,
    Multiply,
    Divide,
    // Compare
    Eq,
    Gt,
    Lt,
    // Logical Arithmetic
    And,
    Or,
    // Whitespaces
    Space,
    Tab,
    NewLine,

    fn toString(self: PunctuationTokenTag) []const u8 {
        return switch (self) {
            .LParenthes => "(",
            .RParenthes => ")",
            .LBracket => "[",
            .RBracket => "]",
            .LBrace => "{",
            .RBrace => "}",
            .Comma => ",",
            .Colon => ":",
            .SemiColon => ";",
            .Period => ".",
            .Plus => "+",
            .Minus => "-",
            .Multiply => "*",
            .Divide => "/",
            .Eq => "=",
            .Ne => "<>",
            .Ge => ">=",
            .Gt => ">",
            .Le => "<=",
            .Lt => "<",
            .And => "&",
            .Or => "|",
            .Define => ":=",
            .Space => " ",
            .Tab => "\t",
            .NewLine => "\n",
        };
    }
    fn toStaticToken(self: PunctuationTokenTag) StaticToken {
        return StaticToken{ .punctuation = self };
    }
};

const KeywordTokenTag = enum {
    Function,
    Break,
    Array,
    While,
    Type,
    Then,
    Else,
    For,
    Var,
    Let,
    End,
    Nil,
    To,
    Of,
    In,
    If,
    Do,

    fn toString(self: KeywordTokenTag) []const u8 {
        return switch (self) {
            .Type => "type",
            .Array => "array",
            .Of => "of",
            .Var => "var",
            .Function => "function",
            .Let => "let",
            .In => "in",
            .End => "end",
            .Nil => "nil",
            .If => "if",
            .Then => "then",
            .Else => "else",
            .While => "while",
            .Do => "do",
            .For => "for",
            .To => "to",
            .Break => "break",
        };
    }
    fn toStaticToken(self: KeywordTokenTag) StaticToken {
        return StaticToken{ .keyword = self };
    }
};

const StaticTokenTag = enum {
    punctuation,
    keyword,
};
const StaticToken = union(StaticTokenTag) {
    punctuation: PunctuationTokenTag,
    keyword: KeywordTokenTag,

    fn toString(self: StaticToken) []const u8 {
        return switch (self) {
            .punctuation => |f| f.toString(),
            .keyword => |f| f.toString(),
        };
    }
    fn toToken(self: StaticToken) Token {
        return Token{
            .static = self,
        };
    }
};

const DynamicTokenTag = enum {
    comment,
    identifier,
};

const DynamicToken = union(DynamicTokenTag) {
    comment: []const u8,
    identifier: []const u8,

    fn fromComment(comment: []const u8) DynamicToken {
        return DynamicToken{ .comment = comment };
    }
    fn fromIdentifer(identifier: []const u8) DynamicToken {
        return DynamicToken{ .identifier = identifier };
    }
    fn toToken(self: DynamicToken) Token {
        return Token{
            .dynamic = self,
        };
    }
    fn toString(self: DynamicToken) []const u8 {
        return switch (self) {
            .comment => |f| f,
            .identifier => |f| f,
        };
    }
};

const TokenTag = enum {
    static,
    dynamic,
};

const Token = union(TokenTag) {
    static: StaticToken,
    dynamic: DynamicToken,

    fn toString(self: Token) []const u8 {
        return switch (self) {
            .static => |f| f.toString(),
            .dynamic => |f| f.toString(),
        };
    }
};

test "StaticTokenToString" {
    try std.testing.expect(std.mem.eql(u8, PunctuationTokenTag.And.toStaticToken().toString(), "&"));
}

test "DynamicTokenToString" {
    try std.testing.expect(std.mem.eql(u8, DynamicToken.fromComment("/* comment */").toToken().toString(), "/* comment */"));
}

const LexerStateTag = enum {
    normal,
    string,
    comment,
};

const LexerState = union(LexerStateTag) {
    normal: void,
    string: void,
    comment: struct {
        level: u32,
    },
};
