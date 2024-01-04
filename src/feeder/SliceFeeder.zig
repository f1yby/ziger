const std = @import("std");
const Error = @import("error.zig").Error;

fn SliceFeeder(comptime T: type) type {
    return struct {
        iter: []const T,
        fn init(slice: []const T) SliceFeeder(T) {
            return SliceFeeder(T){
                .iter = slice,
            };
        }
        fn peek(self: SliceFeeder(T)) Error!T {
            if (self.empty()) {
                return Error.OutOfBound;
            }
            return self.iter[0];
        }
        fn peek_cn(self: SliceFeeder(T), comptime n: usize) Error!*const [n]T {
            if (!self.next_n_in_bound(n)) {
                return Error.OutOfBound;
            }
            return self.iter[0..n];
        }
        fn peek_n(self: SliceFeeder(T), n: usize) Error![]const T {
            if (!self.next_n_in_bound(n)) {
                return Error.OutOfBound;
            }
            return self.iter[0..n];
        }
        fn forward_n(self: *SliceFeeder(T), n: usize) Error!void {
            if (!self.next_n_in_bound(n)) {
                return Error.OutOfBound;
            }
            self.*.iter = self.iter[n..];
        }
        fn empty(self: SliceFeeder(T)) bool {
            return self.iter.len == 0;
        }
        fn next_n_in_bound(self: SliceFeeder(T), n: usize) bool {
            return n <= self.iter.len;
        }
    };
}

test "peek test" {
    const sf = SliceFeeder(u8).init(";");
    try std.testing.expectEqual(try sf.peek(), @as(u8, ';'));
}

test "peek_cn test" {
    const sf = SliceFeeder(u8).init("hello");
    try std.testing.expect(std.mem.eql(u8, try sf.peek_cn(5), "hello"));
}

test "peek_n test" {
    const sf = SliceFeeder(u8).init("hello");
    var n: usize = 5;
    try std.testing.expect(std.mem.eql(u8, try sf.peek_n(n), "hello"));
}

test "empty test" {
    {
        const sf = SliceFeeder(u8).init("hello");
        try std.testing.expectEqual(false, sf.empty());
    }
    {
        const sf = SliceFeeder(u8).init("");
        try std.testing.expectEqual(true, sf.empty());
    }
}

test "forward test" {
    {
        var sf = SliceFeeder(u8).init("hello");
        try sf.forward_n(5);
        try std.testing.expectEqual(true, sf.empty());
    }
    {
        var sf = SliceFeeder(u8).init("hello");
        try sf.forward_n(2);
        try std.testing.expect(std.mem.eql(u8, try sf.peek_n(3), "llo"));
    }
    {
        var sf = SliceFeeder(u8).init("hello");
        try std.testing.expectError(Error.OutOfBound, sf.forward_n(6));
    }
    {
        var sf = SliceFeeder(u8).init("");
        try sf.forward_n(0);
    }
}
