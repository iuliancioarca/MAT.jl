using MAT
using Compat

tmpfile = string(tempname, ".mat")

function test_write(data)
	matwrite(tmpfile, data)

	fid = matopen(tmpfile, "r")
	local result
	try
		result = read(fid)
	finally
		close(fid)
	end

	if !isequal(result, data)
		error("Data mismatch")
	end
end

test_write(@compat Dict(
	"int8" => int8(1),
	"uint8" => uint8(1),
	"int16" => int16(1),
	"uint16" => uint16(1),
	"int32" => int32(1),
	"uint32" => uint32(1),
	"int64" => int64(1),
	"uint64" => uint64(1),
	"single" => float32(1),
	"double" => float64(1),
	"logical" => true
))

test_write(@compat Dict(
	"Complex128" => [1.0 -1.0 1.0+1.0im 1.0-1.0im -1.0+1.0im -1.0-1.0im 1.0im],
	"ComplexPair" => [1 2-3im 4+5im]
))
test_write(@compat Dict("Complex128" => 1.0im, "ComplexPair" => 2-3im))

test_write(@compat Dict(
	"simple_string" => "the quick brown fox",
	"accented_string" => "thé qüîck browñ fòx",
	"concatenated_strings" => ["this is a string", "this is another string"],
	"cell_strings" => ["this is a string" "this is another string"],
	"empty_string" => ""
))

test_write(@compat Dict(
	"a1x2" => [1.0 2.0],
	"a2x1" => zeros(2, 1)+[1.0, 2.0],
	"a2x2" => [1.0 3.0; 4.0 2.0],
	"a2x2x2" => cat(3, [1.0 3.0; 4.0 2.0], [1.0 2.0; 3.0 4.0]),
	"empty" => zeros(0, 0),
	"string" => "string"
))

test_write(@compat Dict(
	"cell" => Any[1 2.01 "string" Any["string1" "string2"]]
))

test_write(@compat Dict(
	"s" => Dict(
		"a" => 1.0,
		"b" => [1.0 2.0],
		"c" => [1.0 2.0 3.0]
	),
	"s2" => Dict("a" => [1.0 2.0])
))

test_write(@compat Dict(
	"sparse_empty" => sparse(Array(Float64, 0, 0)),
	"sparse_eye" => speye(20),
	"sparse_logical" => SparseMatrixCSC{Bool,Int64}(5, 5, [1:6], [1:5], bitunpack(trues(5))),
	"sparse_random" => sparse([0 6. 0; 8. 0 1.; 0 0 9.]),
	"sparse_complex" => sparse([0 6. 0; 8. 0 1.; 0 0 9.]*(1. + 1.im)),
	"sparse_zeros" => SparseMatrixCSC(20, 20, ones(Int, 21), Int[], Float64[])
))

@test_throws ErrorException test_write(@compat Dict("1invalidkey" => "starts with a number"))
@test_throws ErrorException test_write(@compat Dict("another invalid key" => "invalid characters"))
@test_throws ErrorException test_write(@compat Dict("yetanotherinvalidkeyyetanotherinvalidkeyyetanotherinvalidkeyyetanotherinvalidkey" => "too long"))

type TestCompositeKind
	field1::String
end
fid = matopen(tmpfile, "w")
write(fid, "test", TestCompositeKind("test value"))
close(fid)
fid = matopen(tmpfile, "r")
result = read(fid, "test")
close(fid)
@assert result == @compat Dict("field1" => "test value")


fid = matopen(tmpfile, "w")
@test_throws ErrorException write(fid, "1invalidvarname", "1invalidvarvalue")
close(fid)
