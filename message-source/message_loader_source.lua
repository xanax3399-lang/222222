-- Acatel: recovered local loader source; PSU VM removed.
-- The main application is downloaded at runtime and is not present here.
-- See README_RU.txt for scope, original API hooks and verification.
local function pack_return_values(...)
    return {
        n = select("#", ...),
        ...,
    }
end
local function loader_main()
    local account_name, discord_id, account_id, channel, ffi, script_length, loader_version, value_1_7, value_1_8, value_1_9, value_1_10, value_1_11, md5, string_char, string_byte, string_format, string_rep, string_sub, bit_or, bit_and, bit_not, bit_xor, bit_rshift, bit_lshift, word_to_le_bytes, bytes_to_be_word, bytes_to_le_word, split_le_words, swap_word_bytes, md5_constants, md5_f, md5_g, md5_h, md5_i, md5_step, md5_transform, md5_update, md5_finish, base64, extract_bits, base64_encoder, base64_decoder, byte_to_char, concat_bytes, rot47, printable_start, printable_count, is_printable, rotate_printable, rot13, xor32, xor_string, lowercase_alphabet, alphabet, session_token, session_key, encode_field, decode_field, steam_signature, steam_context, steam_http, steam_http_pointer, steam_http_vtable, create_http_request, send_http_request, get_header_size, get_header_value, get_body_size, get_body_data, set_request_param, release_request, HttpRequest, HttpRequest_meta, HttpResponse, HttpResponse_meta, HttpClient, HttpClient_meta, material_interface, material_pointer, material_vtable, current_adapter, get_adapter_info, adapter_index, adapter_info, vgui_interface, vgui_pointer, get_desktop, gpu_name, vendor_id, device_id, desktop_path, hardware_digest, log_message, request_payload, http_client, run_server_modules, server_endpoint, value_1_99, value_1_100, value_1_101, value_1_102, value_1_103, value_1_104, value_1_105, value_1_106, value_1_107, value_1_108, value_1_109, value_1_110, value_1_111, value_1_112, value_1_113, value_1_114, value_1_115, value_1_116, value_1_117, value_1_118, value_1_119, value_1_120, value_1_121, value_1_122, value_1_123, value_1_124, value_1_125, value_1_126, value_1_127
    account_name = "DavidDD"
    discord_id = string.sub
    account_id = string.sub
    channel = string.sub
    ffi = string.sub
    ffi = require
    loader_version = string.sub
    ffi = ffi(("ffi"))
    script_length = readfile
    loader_version = _NAME..(".lua")
    script_length = #(script_length(loader_version))
    value_1_7 = {
    }
    value_1_8 = {
    }
    value_1_10 = string.sub
    value_1_10 = loadstring
    value_1_8[1] = ("loadstring")
    value_1_8[2] = value_1_10
    value_1_9 = {
    }
    value_1_11 = string.sub
    value_1_11 = load
    value_1_9[1] = ("load")
    value_1_9[2] = value_1_11
    value_1_10 = {
    }
    md5 = string.sub
    md5 = assert
    value_1_10[1] = ("assert")
    value_1_10[2] = md5
    value_1_11 = {
    }
    string_char = string.sub
    string_char = tostring
    value_1_11[1] = ("tostring")
    value_1_11[2] = string_char
    md5 = {
    }
    string_byte = string.sub
    string_byte = tonumber
    md5[1] = ("tonumber")
    md5[2] = string_byte
    string_char = {
    }
    string_byte = "pairs"
    string_format = string.sub
    string_format = pairs
    string_char[1] = ("pairs")
    string_char[2] = string_format
    value_1_7[1] = value_1_8
    value_1_7[2] = value_1_9
    value_1_7[3] = value_1_10
    value_1_7[4] = value_1_11
    value_1_7[5] = md5
    value_1_7[6] = string_char
    value_1_9 = #value_1_7
    for value_1_11 = 1, value_1_9, 1 do
        md5 = (value_1_7[value_1_11])[1]
        string_char = (value_1_7[value_1_11])[2]
        string_byte = tostring
        string_format = _G[md5]
        string_byte = string_byte(string_format)
        string_format = "function: NULL"
        string_rep = string.sub
        if string_byte == ("function: NULL") then
            script_length = script_length + 420
        end
    end
    value_1_8 = {
    }
    value_1_9 = {
    }
    value_1_11 = string.sub
    value_1_11 = cast
    value_1_9[1] = ("cast")
    value_1_9[2] = value_1_11
    value_1_10 = {
    }
    md5 = string.sub
    md5 = cdef
    value_1_10[1] = ("cdef")
    value_1_10[2] = md5
    value_1_11 = {
    }
    md5 = "new"
    string_char = string.sub
    string_char = new
    value_1_11[1] = ("new")
    value_1_11[2] = string_char
    value_1_8[1] = value_1_9
    value_1_8[2] = value_1_10
    value_1_8[3] = value_1_11
    value_1_10 = #value_1_8
    for md5 = 1, value_1_10, 1 do
        string_char = (value_1_8[md5])[1]
        string_byte = (value_1_8[md5])[2]
        string_format = tostring
        string_rep = ffi[string_char]
        string_format = string_format(string_rep)
        string_rep = "function: NULL"
        string_sub = string.sub
        if string_format == ("function: NULL") then
            script_length = script_length + 420
        end
    end
    value_1_9 = {
    }
    value_1_10 = {
    }
    md5 = string.sub
    md5 = cast
    value_1_10[1] = ("create")
    value_1_10[2] = md5
    value_1_11 = {
    }
    string_char = string.sub
    string_char = cdef
    value_1_11[1] = ("resume")
    value_1_11[2] = string_char
    md5 = {
    }
    string_char = "new"
    string_byte = string.sub
    string_byte = new
    md5[1] = ("new")
    md5[2] = string_byte
    value_1_9[1] = value_1_10
    value_1_9[2] = value_1_11
    value_1_9[3] = md5
    value_1_11 = #value_1_9
    for string_char = 1, value_1_11, 1 do
        string_byte = (value_1_9[string_char])[1]
        string_format = (value_1_9[string_char])[2]
        string_rep = tostring
        string_sub = _G
        bit_and = string.sub
        string_sub = (string_sub[("coroutine")])[string_byte]
        string_rep = string_rep(string_sub)
        string_sub = "function: NULL"
        bit_or = string.sub
        if string_rep == ("function: NULL") then
            script_length = script_length + 420
        end
    end
    value_1_10 = {
    }
    value_1_11 = {
    }
    string_char = string.sub
    string_char = char
    value_1_11[1] = ("char")
    value_1_11[2] = string_char
    md5 = {
    }
    string_byte = string.sub
    string_byte = format
    md5[1] = ("format")
    md5[2] = string_byte
    string_char = {
    }
    string_format = string.sub
    string_format = sub
    string_char[1] = ("sub")
    string_char[2] = string_format
    string_byte = {
    }
    string_rep = string.sub
    string_rep = rep
    string_byte[1] = ("rep")
    string_byte[2] = string_rep
    string_format = {
    }
    string_rep = "reverse"
    string_sub = string.sub
    string_sub = reverse
    string_format[1] = ("reverse")
    string_format[2] = string_sub
    value_1_10[1] = value_1_11
    value_1_10[2] = md5
    value_1_10[3] = string_char
    value_1_10[4] = string_byte
    value_1_10[5] = string_format
    md5 = #value_1_10
    for string_byte = 1, md5, 1 do
        string_format = (value_1_10[string_byte])[1]
        string_rep = (value_1_10[string_byte])[2]
        string_sub = tostring
        bit_or = _G
        bit_not = string.sub
        bit_or = (bit_or[("string")])[string_format]
        string_sub = string_sub(bit_or)
        bit_or = "function: NULL"
        bit_and = string.sub
        if string_sub == ("function: NULL") then
            script_length = script_length + 420
        end
    end
    value_1_11 = {
    }
    md5 = {
    }
    string_byte = string.sub
    string_byte = concat
    md5[1] = ("concat")
    md5[2] = string_byte
    string_char = {
    }
    string_format = string.sub
    string_format = pack
    string_char[1] = ("pack")
    string_char[2] = string_format
    string_byte = {
    }
    string_format = "unpack"
    string_rep = string.sub
    string_rep = unpack
    string_byte[1] = ("unpack")
    string_byte[2] = string_rep
    value_1_11[1] = md5
    value_1_11[2] = string_char
    value_1_11[3] = string_byte
    string_char = #value_1_11
    for string_format = 1, string_char, 1 do
        string_rep = (value_1_11[string_format])[1]
        string_sub = (value_1_11[string_format])[2]
        bit_or = tostring
        bit_and = _G
        bit_xor = string.sub
        bit_and = (bit_and[("table")])[string_rep]
        bit_or = bit_or(bit_and)
        bit_and = "function: NULL"
        bit_not = string.sub
        if bit_or == ("function: NULL") then
            script_length = script_length + 420
        end
    end
    md5 = tostring
    string_char = _G
    string_format = string.sub
    string_char = string_char[("math")]
    string_format = string.sub
    string_char = string_char[("random")]
    md5 = md5(string_char)
    string_byte = string.sub
    if md5 == ("function: NULL") then
        script_length = script_length + 420
    end
    md5 = {
    }
    string_char = string.char
    string_byte = string.byte
    string_format = string.format
    string_rep = string.rep
    string_sub = string.sub
    bit_or = bit.bor
    bit_and = bit.band
    bit_not = bit.bnot
    bit_xor = bit.bxor
    bit_rshift = bit.rshift
    bit_lshift = bit.lshift
    word_to_le_bytes = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3, value_2_4, value_2_5
        value_2_1 = function(argument_3_0, ...)
            local value_3_2, value_3_3, value_3_4, value_3_5
            value_3_3 = bit_rshift(argument_2_0, argument_3_0)
            local returned_2_4 = pack_return_values(bit_and(value_3_3, 255))
            value_3_2, value_3_3, value_3_4, value_3_5 = unpack(returned_2_4, 1, returned_2_4.n)
            return string_char(unpack(returned_2_4, 1, returned_2_4.n))
        end
        value_2_2 = value_2_1(0)
        value_2_3 = value_2_1(8)
        value_2_4 = value_2_1(16)
        value_2_5 = value_2_1(24)
        value_2_2 = value_2_2..value_2_3..value_2_4..value_2_5
        return value_2_2
    end
    bytes_to_be_word = function(argument_2_0, ...)
        local value_2_1, value_2_3, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9
        value_2_1 = 0
        value_2_3 = #argument_2_0
        for value_2_5 = 1, value_2_3, 1 do
            value_2_6 = value_2_1 * 256
            value_2_8 = argument_2_0
            value_2_9 = value_2_5
            value_2_7 = string_byte(argument_2_0, value_2_5)
            value_2_1 = value_2_6 + value_2_7
        end
        return value_2_1
    end
    bytes_to_le_word = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9
        value_2_1 = 0
        value_2_2 = #argument_2_0
        value_2_4 = -1
        for value_2_5 = value_2_2, 1, value_2_4 do
            value_2_6 = value_2_1 * 256
            value_2_8 = argument_2_0
            value_2_9 = value_2_5
            value_2_7 = string_byte(argument_2_0, value_2_5)
            value_2_1 = value_2_6 + value_2_7
        end
        return value_2_1
    end
    split_le_words = function(argument_2_0, ...)
        local value_2_2, value_2_3, value_2_4, value_2_6, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15
        value_2_2 = 1
        value_2_3 = {
        }
        value_2_4 = {
        }
        value_2_4 = {
            ...,
        }
        value_2_6 = #value_2_4
        for value_2_8 = 1, value_2_6, 1 do
            value_2_9 = table.insert
            value_2_10 = value_2_3
            value_2_15 = value_2_4[value_2_8]
            value_2_15 = (value_2_2 + value_2_15) - 1
            local returned_5_5 = pack_return_values(string_sub(argument_2_0, value_2_2, value_2_15))
            value_2_12, value_2_13, value_2_14, value_2_15 = unpack(returned_5_5, 1, returned_5_5.n)
            local returned_5_6 = pack_return_values(bytes_to_le_word(unpack(returned_5_5, 1, returned_5_5.n)))
            value_2_11, value_2_12, value_2_13, value_2_14, value_2_15 = unpack(returned_5_6, 1, returned_5_6.n)
            value_2_9(value_2_3, unpack(returned_5_6, 1, returned_5_6.n))
            value_2_9 = value_2_4[value_2_8]
            value_2_2 = value_2_2 + value_2_9
        end
        return value_2_3
    end
    swap_word_bytes = function(argument_2_0, ...)
        local value_2_2, value_2_3
        local returned_6_7 = pack_return_values(word_to_le_bytes(argument_2_0))
        value_2_2, value_2_3 = unpack(returned_6_7, 1, returned_6_7.n)
        return bytes_to_be_word(unpack(returned_6_7, 1, returned_6_7.n))
    end
    md5_constants = {
    }
    steam_signature = 1735328473
    steam_context = 2368359562
    steam_http = 4294588738
    steam_http_pointer = 2272392833
    steam_http_vtable = 1839030562
    create_http_request = 4259657740
    send_http_request = 2763975236
    md5_constants[1] = 3614090360
    md5_constants[2] = 3905402710
    md5_constants[3] = 606105819
    md5_constants[4] = 3250441966
    md5_constants[5] = 4118548399
    md5_constants[6] = 1200080426
    md5_constants[7] = 2821735955
    md5_constants[8] = 4249261313
    md5_constants[9] = 1770035416
    md5_constants[10] = 2336552879
    md5_constants[11] = 4294925233
    md5_constants[12] = 2304563134
    md5_constants[13] = 1804603682
    md5_constants[14] = 4254626195
    md5_constants[15] = 2792965006
    md5_constants[16] = 1236535329
    md5_constants[17] = 4129170786
    md5_constants[18] = 3225465664
    md5_constants[19] = 643717713
    md5_constants[20] = 3921069994
    md5_constants[21] = 3593408605
    md5_constants[22] = 38016083
    md5_constants[23] = 3634488961
    md5_constants[24] = 3889429448
    md5_constants[25] = 568446438
    md5_constants[26] = 3275163606
    md5_constants[27] = 4107603335
    md5_constants[28] = 1163531501
    md5_constants[29] = 2850285829
    md5_constants[30] = 4243563512
    md5_constants[31] = 1735328473
    md5_constants[32] = 2368359562
    md5_constants[33] = 4294588738
    md5_constants[34] = 2272392833
    md5_constants[35] = 1839030562
    md5_constants[36] = 4259657740
    md5_constants[37] = 2763975236
    md5_constants[38] = 1272893353
    md5_constants[39] = 4139469664
    md5_constants[40] = 3200236656
    md5_constants[41] = 681279174
    md5_constants[42] = 3936430074
    md5_constants[43] = 3572445317
    md5_constants[44] = 76029189
    md5_constants[45] = 3654602809
    md5_constants[46] = 3873151461
    md5_constants[47] = 530742520
    md5_constants[48] = 3299628645
    md5_constants[49] = 4096336452
    md5_constants[50] = 1126891415
    md5_constants[51] = 2878612391
    md5_constants[52] = 4237533241
    md5_constants[53] = 1700485571
    md5_constants[54] = 2399980690
    md5_constants[55] = 4293915773
    md5_constants[56] = 2240044497
    md5_constants[57] = 1873313359
    md5_constants[58] = 4264355552
    md5_constants[59] = 2734768916
    md5_constants[60] = 1309151649
    md5_constants[61] = 4149444226
    md5_constants[62] = 3174756917
    md5_constants[63] = 718787259
    md5_constants[64] = 3951481745
    md5_constants[65] = 1732584193
    md5_constants[66] = 4023233417
    md5_constants[67] = 2562383102
    md5_constants[68] = 271733878
    md5_f = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_4, value_2_5, value_2_6, value_2_7
        value_2_4 = bit_and(argument_2_0, argument_2_1)
        value_2_6 = (-argument_2_0) - 1
        local returned_7_8 = pack_return_values(bit_and(value_2_6, argument_2_2))
        value_2_5, value_2_6, value_2_7 = unpack(returned_7_8, 1, returned_7_8.n)
        return bit_or(value_2_4, unpack(returned_7_8, 1, returned_7_8.n))
    end
    md5_g = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_4, value_2_5, value_2_6, value_2_7
        value_2_4 = bit_and(argument_2_0, argument_2_2)
        value_2_7 = (-argument_2_2) - 1
        local returned_8_9 = pack_return_values(bit_and(argument_2_1, value_2_7))
        value_2_5, value_2_6, value_2_7 = unpack(returned_8_9, 1, returned_8_9.n)
        return bit_or(value_2_4, unpack(returned_8_9, 1, returned_8_9.n))
    end
    md5_h = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_5, value_2_6, value_2_7
        local returned_9_10 = pack_return_values(bit_xor(argument_2_1, argument_2_2))
        value_2_5, value_2_6, value_2_7 = unpack(returned_9_10, 1, returned_9_10.n)
        return bit_xor(argument_2_0, unpack(returned_9_10, 1, returned_9_10.n))
    end
    md5_i = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_5, value_2_6, value_2_7
        value_2_7 = (-argument_2_2) - 1
        local returned_10_11 = pack_return_values(bit_or(argument_2_0, value_2_7))
        value_2_5, value_2_6, value_2_7 = unpack(returned_10_11, 1, returned_10_11.n)
        return bit_xor(argument_2_1, unpack(returned_10_11, 1, returned_10_11.n))
    end
    md5_step = function(argument_2_0, argument_2_1, argument_2_2, argument_2_3, argument_2_4, argument_2_5, argument_2_6, argument_2_7, ...)
        local value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14
        value_2_9 = argument_2_0(argument_2_2, argument_2_3, argument_2_4)
        value_2_9 = ((argument_2_1 + value_2_9) + argument_2_5) + argument_2_7
        argument_2_1 = bit_and(value_2_9, 4294967295)
        local returned_11_12 = pack_return_values(bit_rshift(4294967295, argument_2_6))
        value_2_12, value_2_13, value_2_14 = unpack(returned_11_12, 1, returned_11_12.n)
        value_2_10 = bit_and(argument_2_1, unpack(returned_11_12, 1, returned_11_12.n))
        value_2_9 = bit_lshift(value_2_10, argument_2_6)
        value_2_12 = 32 - argument_2_6
        local returned_11_13 = pack_return_values(bit_rshift(argument_2_1, value_2_12))
        value_2_10, value_2_11, value_2_12, value_2_13, value_2_14 = unpack(returned_11_13, 1, returned_11_13.n)
        value_2_8 = (bit_or(value_2_9, unpack(returned_11_13, 1, returned_11_13.n))) + argument_2_2
        return value_2_8
    end
    md5_transform = function(argument_2_0, argument_2_1, argument_2_2, argument_2_3, argument_2_4, ...)
        local value_2_5, value_2_6, value_2_7, value_2_8, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18
        value_2_16 = argument_2_4[0]
        value_2_18 = md5_constants[1]
        value_2_5 = md5_step(md5_f, argument_2_0, argument_2_1, argument_2_2, argument_2_3, value_2_16, 7, value_2_18)
        value_2_16 = argument_2_4[1]
        value_2_18 = md5_constants[2]
        value_2_8 = md5_step(md5_f, argument_2_3, value_2_5, argument_2_1, argument_2_2, value_2_16, 12, value_2_18)
        value_2_16 = argument_2_4[2]
        value_2_18 = md5_constants[3]
        value_2_7 = md5_step(md5_f, argument_2_2, value_2_8, value_2_5, argument_2_1, value_2_16, 17, value_2_18)
        value_2_16 = argument_2_4[3]
        value_2_18 = md5_constants[4]
        value_2_6 = md5_step(md5_f, argument_2_1, value_2_7, value_2_8, value_2_5, value_2_16, 22, value_2_18)
        value_2_16 = argument_2_4[4]
        value_2_18 = md5_constants[5]
        value_2_5 = md5_step(md5_f, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 7, value_2_18)
        value_2_16 = argument_2_4[5]
        value_2_18 = md5_constants[6]
        value_2_8 = md5_step(md5_f, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 12, value_2_18)
        value_2_16 = argument_2_4[6]
        value_2_18 = md5_constants[7]
        value_2_7 = md5_step(md5_f, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 17, value_2_18)
        value_2_16 = argument_2_4[7]
        value_2_18 = md5_constants[8]
        value_2_6 = md5_step(md5_f, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 22, value_2_18)
        value_2_16 = argument_2_4[8]
        value_2_18 = md5_constants[9]
        value_2_5 = md5_step(md5_f, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 7, value_2_18)
        value_2_16 = argument_2_4[9]
        value_2_18 = md5_constants[10]
        value_2_8 = md5_step(md5_f, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 12, value_2_18)
        value_2_16 = argument_2_4[10]
        value_2_18 = md5_constants[11]
        value_2_7 = md5_step(md5_f, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 17, value_2_18)
        value_2_16 = argument_2_4[11]
        value_2_18 = md5_constants[12]
        value_2_6 = md5_step(md5_f, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 22, value_2_18)
        value_2_16 = argument_2_4[12]
        value_2_18 = md5_constants[13]
        value_2_5 = md5_step(md5_f, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 7, value_2_18)
        value_2_16 = argument_2_4[13]
        value_2_18 = md5_constants[14]
        value_2_8 = md5_step(md5_f, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 12, value_2_18)
        value_2_16 = argument_2_4[14]
        value_2_18 = md5_constants[15]
        value_2_7 = md5_step(md5_f, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 17, value_2_18)
        value_2_16 = argument_2_4[15]
        value_2_18 = md5_constants[16]
        value_2_6 = md5_step(md5_f, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 22, value_2_18)
        value_2_16 = argument_2_4[1]
        value_2_18 = md5_constants[17]
        value_2_5 = md5_step(md5_g, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 5, value_2_18)
        value_2_16 = argument_2_4[6]
        value_2_18 = md5_constants[18]
        value_2_8 = md5_step(md5_g, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 9, value_2_18)
        value_2_16 = argument_2_4[11]
        value_2_18 = md5_constants[19]
        value_2_7 = md5_step(md5_g, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 14, value_2_18)
        value_2_16 = argument_2_4[0]
        value_2_18 = md5_constants[20]
        value_2_6 = md5_step(md5_g, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 20, value_2_18)
        value_2_16 = argument_2_4[5]
        value_2_18 = md5_constants[21]
        value_2_5 = md5_step(md5_g, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 5, value_2_18)
        value_2_16 = argument_2_4[10]
        value_2_18 = md5_constants[22]
        value_2_8 = md5_step(md5_g, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 9, value_2_18)
        value_2_16 = argument_2_4[15]
        value_2_18 = md5_constants[23]
        value_2_7 = md5_step(md5_g, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 14, value_2_18)
        value_2_16 = argument_2_4[4]
        value_2_18 = md5_constants[24]
        value_2_6 = md5_step(md5_g, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 20, value_2_18)
        value_2_16 = argument_2_4[9]
        value_2_18 = md5_constants[25]
        value_2_5 = md5_step(md5_g, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 5, value_2_18)
        value_2_16 = argument_2_4[14]
        value_2_18 = md5_constants[26]
        value_2_8 = md5_step(md5_g, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 9, value_2_18)
        value_2_16 = argument_2_4[3]
        value_2_18 = md5_constants[27]
        value_2_7 = md5_step(md5_g, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 14, value_2_18)
        value_2_16 = argument_2_4[8]
        value_2_18 = md5_constants[28]
        value_2_6 = md5_step(md5_g, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 20, value_2_18)
        value_2_16 = argument_2_4[13]
        value_2_18 = md5_constants[29]
        value_2_5 = md5_step(md5_g, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 5, value_2_18)
        value_2_16 = argument_2_4[2]
        value_2_18 = md5_constants[30]
        value_2_8 = md5_step(md5_g, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 9, value_2_18)
        value_2_16 = argument_2_4[7]
        value_2_18 = md5_constants[31]
        value_2_7 = md5_step(md5_g, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 14, value_2_18)
        value_2_16 = argument_2_4[12]
        value_2_18 = md5_constants[32]
        value_2_6 = md5_step(md5_g, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 20, value_2_18)
        value_2_16 = argument_2_4[5]
        value_2_18 = md5_constants[33]
        value_2_5 = md5_step(md5_h, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 4, value_2_18)
        value_2_16 = argument_2_4[8]
        value_2_18 = md5_constants[34]
        value_2_8 = md5_step(md5_h, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 11, value_2_18)
        value_2_16 = argument_2_4[11]
        value_2_18 = md5_constants[35]
        value_2_7 = md5_step(md5_h, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 16, value_2_18)
        value_2_16 = argument_2_4[14]
        value_2_18 = md5_constants[36]
        value_2_6 = md5_step(md5_h, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 23, value_2_18)
        value_2_16 = argument_2_4[1]
        value_2_18 = md5_constants[37]
        value_2_5 = md5_step(md5_h, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 4, value_2_18)
        value_2_16 = argument_2_4[4]
        value_2_18 = md5_constants[38]
        value_2_8 = md5_step(md5_h, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 11, value_2_18)
        value_2_16 = argument_2_4[7]
        value_2_18 = md5_constants[39]
        value_2_7 = md5_step(md5_h, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 16, value_2_18)
        value_2_16 = argument_2_4[10]
        value_2_18 = md5_constants[40]
        value_2_6 = md5_step(md5_h, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 23, value_2_18)
        value_2_16 = argument_2_4[13]
        value_2_18 = md5_constants[41]
        value_2_5 = md5_step(md5_h, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 4, value_2_18)
        value_2_16 = argument_2_4[0]
        value_2_18 = md5_constants[42]
        value_2_8 = md5_step(md5_h, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 11, value_2_18)
        value_2_16 = argument_2_4[3]
        value_2_18 = md5_constants[43]
        value_2_7 = md5_step(md5_h, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 16, value_2_18)
        value_2_16 = argument_2_4[6]
        value_2_18 = md5_constants[44]
        value_2_6 = md5_step(md5_h, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 23, value_2_18)
        value_2_16 = argument_2_4[9]
        value_2_18 = md5_constants[45]
        value_2_5 = md5_step(md5_h, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 4, value_2_18)
        value_2_16 = argument_2_4[12]
        value_2_18 = md5_constants[46]
        value_2_8 = md5_step(md5_h, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 11, value_2_18)
        value_2_16 = argument_2_4[15]
        value_2_18 = md5_constants[47]
        value_2_7 = md5_step(md5_h, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 16, value_2_18)
        value_2_16 = argument_2_4[2]
        value_2_18 = md5_constants[48]
        value_2_6 = md5_step(md5_h, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 23, value_2_18)
        value_2_16 = argument_2_4[0]
        value_2_18 = md5_constants[49]
        value_2_5 = md5_step(md5_i, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 6, value_2_18)
        value_2_16 = argument_2_4[7]
        value_2_18 = md5_constants[50]
        value_2_8 = md5_step(md5_i, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 10, value_2_18)
        value_2_16 = argument_2_4[14]
        value_2_18 = md5_constants[51]
        value_2_7 = md5_step(md5_i, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 15, value_2_18)
        value_2_16 = argument_2_4[5]
        value_2_18 = md5_constants[52]
        value_2_6 = md5_step(md5_i, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 21, value_2_18)
        value_2_16 = argument_2_4[12]
        value_2_18 = md5_constants[53]
        value_2_5 = md5_step(md5_i, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 6, value_2_18)
        value_2_16 = argument_2_4[3]
        value_2_18 = md5_constants[54]
        value_2_8 = md5_step(md5_i, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 10, value_2_18)
        value_2_16 = argument_2_4[10]
        value_2_18 = md5_constants[55]
        value_2_7 = md5_step(md5_i, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 15, value_2_18)
        value_2_16 = argument_2_4[1]
        value_2_18 = md5_constants[56]
        value_2_6 = md5_step(md5_i, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 21, value_2_18)
        value_2_16 = argument_2_4[8]
        value_2_18 = md5_constants[57]
        value_2_5 = md5_step(md5_i, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 6, value_2_18)
        value_2_16 = argument_2_4[15]
        value_2_18 = md5_constants[58]
        value_2_8 = md5_step(md5_i, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 10, value_2_18)
        value_2_16 = argument_2_4[6]
        value_2_18 = md5_constants[59]
        value_2_7 = md5_step(md5_i, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 15, value_2_18)
        value_2_16 = argument_2_4[13]
        value_2_18 = md5_constants[60]
        value_2_6 = md5_step(md5_i, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 21, value_2_18)
        value_2_16 = argument_2_4[4]
        value_2_18 = md5_constants[61]
        value_2_5 = md5_step(md5_i, value_2_5, value_2_6, value_2_7, value_2_8, value_2_16, 6, value_2_18)
        value_2_16 = argument_2_4[11]
        value_2_18 = md5_constants[62]
        value_2_8 = md5_step(md5_i, value_2_8, value_2_5, value_2_6, value_2_7, value_2_16, 10, value_2_18)
        value_2_16 = argument_2_4[2]
        value_2_18 = md5_constants[63]
        value_2_7 = md5_step(md5_i, value_2_7, value_2_8, value_2_5, value_2_6, value_2_16, 15, value_2_18)
        value_2_16 = argument_2_4[9]
        value_2_18 = md5_constants[64]
        value_2_6 = md5_step(md5_i, value_2_6, value_2_7, value_2_8, value_2_5, value_2_16, 21, value_2_18)
        value_2_11 = argument_2_0 + value_2_5
        value_2_10 = bit_and(value_2_11, 4294967295)
        value_2_12 = argument_2_1 + value_2_6
        value_2_11 = bit_and(value_2_12, 4294967295)
        value_2_13 = argument_2_2 + value_2_7
        value_2_12 = bit_and(value_2_13, 4294967295)
        value_2_14 = argument_2_3 + value_2_8
        local returned_12_14 = pack_return_values(bit_and(value_2_14, 4294967295))
        value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18 = unpack(returned_12_14, 1, returned_12_14.n)
        return value_2_10, value_2_11, value_2_12, unpack(returned_12_14, 1, returned_12_14.n)
    end
    md5_update = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23
        value_2_2 = argument_2_0.pos
        value_2_3 = #argument_2_1
        argument_2_0.pos = value_2_2 + value_2_3
        value_2_2 = argument_2_0.buf
        argument_2_1 = value_2_2..argument_2_1
        value_2_3 = (#argument_2_1) - 63
        for value_2_5 = 1, value_2_3, 64 do
            value_2_10 = value_2_5 + 63
            value_2_7 = string_sub(argument_2_1, value_2_5, value_2_10)
            value_2_13 = 4
            value_2_14 = 4
            value_2_15 = 4
            value_2_16 = 4
            value_2_17 = 4
            value_2_18 = 4
            value_2_19 = 4
            value_2_20 = 4
            value_2_21 = 4
            value_2_22 = 4
            value_2_23 = 4
            value_2_6 = split_le_words(value_2_7, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4)
            value_2_7 = assert
            value_2_8 = #value_2_6
            if value_2_8 ~= 16 then
                value_2_8 = false
            else
                value_2_8 = true
            end
            value_2_7(value_2_8)
            value_2_6[0] = (table.remove)(value_2_6, 1)
            value_2_8 = argument_2_0.a
            value_2_9 = argument_2_0.b
            value_2_10 = argument_2_0.c
            value_2_11 = argument_2_0.d
            value_2_12 = value_2_6
            value_2_7, value_2_8, value_2_9, value_2_10 = md5_transform(value_2_8, value_2_9, value_2_10, value_2_11, value_2_6)
            argument_2_0.d = value_2_10
            argument_2_0.c = value_2_9
            argument_2_0.b = value_2_8
            argument_2_0.a = value_2_7
        end
        value_2_4 = math.floor
        value_2_5 = (#argument_2_1) / 64
        value_2_4 = ((value_2_4(value_2_5)) * 64) + 1
        value_2_5 = #argument_2_1
        argument_2_0.buf = string_sub(argument_2_1, value_2_4, value_2_5)
        return argument_2_0
    end
    md5_finish = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8
        value_2_1 = argument_2_0.pos
        value_2_2 = value_2_1 % 64
        value_2_2 = 56 - value_2_2
        value_2_3 = value_2_1 % 64
        if 56 < value_2_3 then
            value_2_2 = value_2_2 + 64
        end
        if value_2_2 == 0 then
            value_2_2 = 64
        end
        value_2_3 = string_char(128)
        value_2_5 = string_char(0)
        value_2_6 = value_2_2 - 1
        value_2_4 = string_rep(value_2_5, value_2_6)
        value_2_7 = 8 * value_2_1
        local returned_14_15 = pack_return_values(bit_and(value_2_7, 4294967295))
        value_2_6, value_2_7, value_2_8 = unpack(returned_14_15, 1, returned_14_15.n)
        value_2_5 = word_to_le_bytes(unpack(returned_14_15, 1, returned_14_15.n))
        value_2_7 = math.floor
        value_2_8 = value_2_1 / 536870912
        local returned_14_16 = pack_return_values(value_2_7(value_2_8))
        value_2_7, value_2_8 = unpack(returned_14_16, 1, returned_14_16.n)
        value_2_6 = word_to_le_bytes(unpack(returned_14_16, 1, returned_14_16.n))
        value_2_3 = value_2_3..value_2_4..value_2_5..value_2_6
        md5_update(argument_2_0, value_2_3)
        value_2_4 = assert
        value_2_5 = (argument_2_0.pos) % 64
        if value_2_5 ~= 0 then
            value_2_5 = false
        else
            value_2_5 = true
        end
        value_2_4(value_2_5)
        value_2_5 = argument_2_0.a
        value_2_4 = word_to_le_bytes(value_2_5)
        value_2_6 = argument_2_0.b
        value_2_5 = word_to_le_bytes(value_2_6)
        value_2_7 = argument_2_0.c
        value_2_6 = word_to_le_bytes(value_2_7)
        value_2_8 = argument_2_0.d
        value_2_7 = word_to_le_bytes(value_2_8)
        value_2_4 = value_2_4..value_2_5..value_2_6..value_2_7
        return value_2_4
    end
    base64 = function(...)
        local value_2_0
        value_2_0 = {
        }
        value_2_0.a = md5_constants[65]
        value_2_0.b = md5_constants[66]
        value_2_0.c = md5_constants[67]
        value_2_0.d = md5_constants[68]
        value_2_0.pos = 0
        value_2_0.buf = ""
        value_2_0.update = md5_update
        value_2_0.finish = md5_finish
        return value_2_0
    end
    md5.new = base64
    base64 = function(argument_2_0, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10
        local returned_16_17 = pack_return_values(string_sub(argument_2_0, 1, 4))
        value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10 = unpack(returned_16_17, 1, returned_16_17.n)
        value_2_3 = bytes_to_be_word(unpack(returned_16_17, 1, returned_16_17.n))
        local returned_16_18 = pack_return_values(string_sub(argument_2_0, 5, 8))
        value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10 = unpack(returned_16_18, 1, returned_16_18.n)
        value_2_4 = bytes_to_be_word(unpack(returned_16_18, 1, returned_16_18.n))
        local returned_16_19 = pack_return_values(string_sub(argument_2_0, 9, 12))
        value_2_6, value_2_7, value_2_8, value_2_9, value_2_10 = unpack(returned_16_19, 1, returned_16_19.n)
        value_2_5 = bytes_to_be_word(unpack(returned_16_19, 1, returned_16_19.n))
        local returned_16_20 = pack_return_values(string_sub(argument_2_0, 13, 16))
        value_2_7, value_2_8, value_2_9, value_2_10 = unpack(returned_16_20, 1, returned_16_20.n)
        local returned_16_21 = pack_return_values(bytes_to_be_word(unpack(returned_16_20, 1, returned_16_20.n)))
        value_2_6, value_2_7, value_2_8, value_2_9, value_2_10 = unpack(returned_16_21, 1, returned_16_21.n)
        return string_format(("%08x%08x%08x%08x"), value_2_3, value_2_4, value_2_5, unpack(returned_16_21, 1, returned_16_21.n))
    end
    md5.tohex = base64
    base64 = function(argument_2_0, ...)
        local value_2_1, value_2_2
        value_2_1 = (md5.new)()
        value_2_2 = value_2_1
        value_2_1 = (value_2_1.update)(value_2_2, argument_2_0)
        value_2_2 = value_2_1
        value_2_1 = value_2_1.finish
        return value_2_1(value_2_2)
    end
    md5.sum = base64
    base64 = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3
        value_2_1 = md5.tohex
        value_2_2 = md5.sum
        local returned_18_22 = pack_return_values(value_2_2(argument_2_0))
        value_2_2, value_2_3 = unpack(returned_18_22, 1, returned_18_22.n)
        return value_2_1(unpack(returned_18_22, 1, returned_18_22.n))
    end
    md5.sumhexa = base64
    base64 = {
    }
    extract_bits = _G.bit32
    if extract_bits then
        extract_bits = (_G.bit32).extract
    end
    if not extract_bits then
        base64_encoder = _G.bit
        if base64_encoder then
            local captured_lshift, captured_rshift, captured_band
            captured_lshift = (_G.bit).lshift
            captured_rshift = (_G.bit).rshift
            captured_band = (_G.bit).band
            extract_bits = function(argument_2_0, argument_2_1, argument_2_2, ...)
                local value_2_4, value_2_5
                value_2_4 = captured_rshift(argument_2_0, argument_2_1)
                value_2_5 = (captured_lshift(1, argument_2_2)) - 1
                return captured_band(value_2_4, value_2_5)
            end
        else
            base64_encoder = _G._VERSION
            if base64_encoder == "Lua 5.1" then
                extract_bits = function(argument_2_0, argument_2_1, argument_2_2, ...)
                    local value_2_3, value_2_4, value_2_6, value_2_8, value_2_9, value_2_10
                    value_2_3 = 0
                    value_2_4 = 2 ^ argument_2_1
                    value_2_6 = argument_2_2 - 1
                    for value_2_8 = 0, value_2_6, 1 do
                        value_2_9 = value_2_4 + value_2_4
                        value_2_10 = argument_2_0 % value_2_9
                        if value_2_4 <= value_2_10 then
                            value_2_10 = 2 ^ value_2_8
                            value_2_3 = value_2_3 + value_2_10
                        end
                        value_2_4 = value_2_9
                    end
                    return value_2_3
                end
            else
                extract_bits = (loadstring(("return function( v, from, width ) return ( v >> from ) & ((1 << width) - 1) end")))()
            end
        end
    end
    base64_encoder = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_17, value_2_18, value_2_19
        value_2_3 = {
        }
        value_2_4 = pairs
        value_2_5 = {
        }
        value_2_5[0] = "A"
        value_2_5[1] = ("B")
        value_2_5[2] = ("C")
        value_2_5[3] = ("D")
        value_2_5[4] = ("E")
        value_2_5[5] = ("F")
        value_2_5[6] = ("G")
        value_2_5[7] = ("H")
        value_2_5[8] = ("I")
        value_2_5[9] = ("J")
        value_2_5[10] = ("K")
        value_2_5[11] = ("L")
        value_2_5[12] = ("M")
        value_2_5[13] = ("N")
        value_2_5[14] = ("O")
        value_2_5[15] = ("P")
        value_2_5[16] = ("Q")
        value_2_5[17] = ("R")
        value_2_5[18] = ("S")
        value_2_5[19] = ("T")
        value_2_5[20] = ("U")
        value_2_5[21] = ("V")
        value_2_5[22] = ("W")
        value_2_5[23] = ("X")
        value_2_5[24] = ("Y")
        value_2_5[25] = ("Z")
        value_2_5[26] = ("a")
        value_2_5[27] = ("b")
        value_2_5[28] = ("c")
        value_2_5[29] = ("d")
        value_2_5[30] = ("e")
        value_2_5[31] = ("f")
        value_2_5[32] = ("g")
        value_2_5[33] = ("h")
        value_2_5[34] = ("i")
        value_2_5[35] = ("j")
        value_2_5[36] = ("k")
        value_2_5[37] = ("l")
        value_2_5[38] = ("m")
        value_2_5[39] = ("n")
        value_2_5[40] = ("o")
        value_2_5[41] = ("p")
        value_2_5[42] = ("q")
        value_2_5[43] = ("r")
        value_2_5[44] = ("s")
        value_2_5[45] = ("t")
        value_2_5[46] = ("u")
        value_2_5[47] = ("v")
        value_2_5[48] = ("w")
        value_2_5[49] = ("x")
        value_2_5[50] = ("y")
        value_2_7 = "0"
        value_2_8 = "1"
        value_2_9 = "2"
        value_2_10 = "3"
        value_2_17 = argument_2_0 or ("M")
        if not argument_2_0 then
            value_2_17 = "+"
        end
        value_2_18 = argument_2_1 or ("N")
        if not argument_2_1 then
            value_2_18 = "/"
        end
        value_2_19 = argument_2_2 or ("O")
        if not argument_2_2 then
            value_2_19 = "="
        end
        value_2_5[51] = ("z")
        value_2_5[52] = ("0")
        value_2_5[53] = ("1")
        value_2_5[54] = ("2")
        value_2_5[55] = ("3")
        value_2_5[56] = ("4")
        value_2_5[57] = ("5")
        value_2_5[58] = ("6")
        value_2_5[59] = ("7")
        value_2_5[60] = ("8")
        value_2_5[61] = ("9")
        value_2_5[62] = value_2_17
        value_2_5[63] = value_2_18
        value_2_5[64] = value_2_19
        value_2_4, value_2_5, value_2_6 = value_2_4(value_2_5)
        for value_2_7, value_2_8 in value_2_4, value_2_5, value_2_6 do
            if not value_2_7 then
                break
            end
            value_2_10 = value_2_8
            value_2_9 = (value_2_8.byte)(value_2_8)
            value_2_3[value_2_7] = value_2_9
        end
        return value_2_3
    end
    base64.makeencoder = base64_encoder
    base64_encoder = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8
        value_2_3 = {
        }
        value_2_4 = pairs
        value_2_5 = base64.makeencoder
        local returned_22_23 = pack_return_values(value_2_5(argument_2_0, argument_2_1, argument_2_2))
        value_2_5, value_2_6, value_2_7, value_2_8 = unpack(returned_22_23, 1, returned_22_23.n)
        value_2_4, value_2_5, value_2_6 = value_2_4(unpack(returned_22_23, 1, returned_22_23.n))
        for value_2_7, value_2_8 in value_2_4, value_2_5, value_2_6 do
            if not value_2_7 then
                break
            end
            value_2_3[value_2_8] = value_2_7
        end
        return value_2_3
    end
    base64.makedecoder = base64_encoder
    base64_encoder = (base64.makeencoder)()
    base64_decoder = (base64.makedecoder)()
    byte_to_char = string.char
    concat_bytes = table.concat
    rot47 = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23, value_2_24
        if not argument_2_1 then
            argument_2_1 = base64_encoder
        end
        value_2_3 = {
        }
        value_2_4 = 1
        value_2_5 = #argument_2_0
        value_2_6 = value_2_5 % 3
        value_2_7 = {
        }
        value_2_9 = value_2_5 - value_2_6
        for value_2_11 = 1, value_2_9, 3 do
            value_2_12 = argument_2_0.byte
            value_2_15 = value_2_11 + 2
            value_2_12, value_2_13, value_2_14 = value_2_12(argument_2_0, value_2_11, value_2_15)
            value_2_15 = value_2_12 * 65536
            value_2_16 = value_2_13 * 256
            value_2_15 = (value_2_15 + value_2_16) + value_2_14
            if argument_2_2 then
                value_2_16 = value_2_7[value_2_15]
                if not value_2_16 then
                    value_2_18 = extract_bits(value_2_15, 18, 6)
                    value_2_18 = argument_2_1[value_2_18]
                    value_2_19 = extract_bits(value_2_15, 12, 6)
                    value_2_19 = argument_2_1[value_2_19]
                    value_2_20 = extract_bits(value_2_15, 6, 6)
                    value_2_20 = argument_2_1[value_2_20]
                    value_2_22 = value_2_15
                    value_2_23 = 0
                    value_2_24 = 6
                    value_2_21 = extract_bits(value_2_15, 0, 6)
                    value_2_21 = argument_2_1[value_2_21]
                    value_2_17 = byte_to_char(value_2_18, value_2_19, value_2_20, value_2_21)
                    value_2_16 = value_2_17
                    value_2_7[value_2_15] = value_2_17
                end
            else
                value_2_18 = extract_bits(value_2_15, 18, 6)
                value_2_18 = argument_2_1[value_2_18]
                value_2_19 = extract_bits(value_2_15, 12, 6)
                value_2_19 = argument_2_1[value_2_19]
                value_2_20 = extract_bits(value_2_15, 6, 6)
                value_2_20 = argument_2_1[value_2_20]
                value_2_22 = value_2_15
                value_2_23 = 0
                value_2_24 = 6
                value_2_21 = extract_bits(value_2_15, 0, 6)
                value_2_21 = argument_2_1[value_2_21]
                value_2_17 = byte_to_char(value_2_18, value_2_19, value_2_20, value_2_21)
                value_2_16 = value_2_17
            end
            value_2_3[value_2_4] = value_2_16
            value_2_4 = value_2_4 + 1
        end
        if value_2_6 == 2 then
            value_2_8 = argument_2_0.byte
            value_2_10 = value_2_5 - 1
            value_2_8, value_2_9 = value_2_8(argument_2_0, value_2_10, value_2_5)
            value_2_10 = value_2_8 * 65536
            value_2_11 = value_2_9 * 256
            value_2_10 = value_2_10 + value_2_11
            value_2_12 = extract_bits(value_2_10, 18, 6)
            value_2_12 = argument_2_1[value_2_12]
            value_2_13 = extract_bits(value_2_10, 12, 6)
            value_2_13 = argument_2_1[value_2_13]
            value_2_14 = extract_bits(value_2_10, 6, 6)
            value_2_14 = argument_2_1[value_2_14]
            value_2_15 = argument_2_1[64]
            value_2_11 = byte_to_char(value_2_12, value_2_13, value_2_14, value_2_15)
            value_2_3[value_2_4] = value_2_11
        else
            if value_2_6 == 1 then
                value_2_8 = ((argument_2_0.byte)(argument_2_0, value_2_5)) * 65536
                value_2_10 = extract_bits(value_2_8, 18, 6)
                value_2_10 = argument_2_1[value_2_10]
                value_2_11 = extract_bits(value_2_8, 12, 6)
                value_2_11 = argument_2_1[value_2_11]
                value_2_12 = argument_2_1[64]
                value_2_13 = argument_2_1[64]
                value_2_9 = byte_to_char(value_2_10, value_2_11, value_2_12, value_2_13)
                value_2_3[value_2_4] = value_2_9
            end
        end
        return concat_bytes(value_2_3)
    end
    base64.encode = rot47
    rot47 = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23, value_2_24, value_2_25, value_2_26
        if not argument_2_1 then
            argument_2_1 = base64_decoder
        end
        value_2_3 = "[^%w%+%/%=]"
        if argument_2_1 then
            value_2_4 = nil
            value_2_5 = nil
            value_2_6, value_2_7, value_2_8 = pairs(argument_2_1)
            for value_2_9, value_2_10 in value_2_6, value_2_7, value_2_8 do
                if not value_2_9 then
                    break
                end
                if value_2_10 == 62 then
                    value_2_4 = value_2_9
                else
                    if value_2_10 == 63 then
                        value_2_5 = value_2_9
                    end
                end
            end
            value_2_6 = ("[^%%w%%%s%%%s%%=]").format
            value_2_8 = byte_to_char(value_2_4)
            local returned_24_24 = pack_return_values(byte_to_char(value_2_5))
            value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23, value_2_24, value_2_25, value_2_26 = unpack(returned_24_24, 1, returned_24_24.n)
            value_2_3 = value_2_6(("[^%%w%%%s%%%s%%=]"), value_2_8, unpack(returned_24_24, 1, returned_24_24.n))
        end
        value_2_4 = (argument_2_0.gsub)(argument_2_0, value_2_3, (""))
        argument_2_0 = value_2_4
        value_2_4 = argument_2_2 or value_2_4
        if argument_2_2 then
            value_2_4 = {
            }
        end
        value_2_5 = {
        }
        value_2_6 = 1
        value_2_7 = #argument_2_0
        value_2_8 = argument_2_0.sub
        value_2_10 = -2
        value_2_8 = value_2_8(argument_2_0, value_2_10)
        if value_2_8 == "==" then
            value_2_8 = 2
            if not 2 then
                value_2_8 = argument_2_0.sub
                value_2_10 = -1
                value_2_8 = value_2_8(argument_2_0, value_2_10)
                if value_2_8 == "=" then
                    value_2_8 = 1
                    if not 1 then
                        value_2_8 = 0
                    end
                else
                    value_2_8 = 0
                end
            end
        else
            value_2_8 = argument_2_0.sub
            value_2_10 = -1
            value_2_8 = value_2_8(argument_2_0, value_2_10)
            if value_2_8 == "=" then
                value_2_8 = 1
                if not 1 then
                    value_2_8 = 0
                end
            else
                value_2_8 = 0
            end
        end
        if 0 < value_2_8 then
            value_2_10 = value_2_7 - 4
            if not (value_2_10) then
                value_2_10 = value_2_7
            end
        else
            value_2_10 = value_2_7
        end
        for value_2_12 = 1, value_2_10, 4 do
            value_2_13 = argument_2_0.byte
            value_2_16 = value_2_12 + 3
            value_2_13, value_2_14, value_2_15, value_2_16 = value_2_13(argument_2_0, value_2_12, value_2_16)
            if argument_2_2 then
                value_2_18 = value_2_13 * 16777216
                value_2_19 = value_2_14 * 65536
                value_2_18 = value_2_18 + value_2_19
                value_2_19 = value_2_15 * 256
                value_2_18 = (value_2_18 + value_2_19) + value_2_16
                value_2_17 = value_2_4[value_2_18]
                if not value_2_17 then
                    value_2_19 = (argument_2_1[value_2_13]) * 262144
                    value_2_20 = (argument_2_1[value_2_14]) * 4096
                    value_2_19 = value_2_19 + value_2_20
                    value_2_20 = (argument_2_1[value_2_15]) * 64
                    value_2_19 = value_2_19 + value_2_20
                    value_2_20 = argument_2_1[value_2_16]
                    value_2_19 = value_2_19 + value_2_20
                    value_2_21 = extract_bits(value_2_19, 16, 8)
                    value_2_22 = extract_bits(value_2_19, 8, 8)
                    local returned_24_25 = pack_return_values(extract_bits(value_2_19, 0, 8))
                    value_2_23, value_2_24, value_2_25, value_2_26 = unpack(returned_24_25, 1, returned_24_25.n)
                    value_2_20 = byte_to_char(value_2_21, value_2_22, unpack(returned_24_25, 1, returned_24_25.n))
                    value_2_17 = value_2_20
                    value_2_4[value_2_18] = value_2_20
                end
            else
                value_2_18 = (argument_2_1[value_2_13]) * 262144
                value_2_19 = (argument_2_1[value_2_14]) * 4096
                value_2_18 = value_2_18 + value_2_19
                value_2_19 = (argument_2_1[value_2_15]) * 64
                value_2_18 = value_2_18 + value_2_19
                value_2_19 = argument_2_1[value_2_16]
                value_2_18 = value_2_18 + value_2_19
                value_2_20 = extract_bits(value_2_18, 16, 8)
                value_2_21 = extract_bits(value_2_18, 8, 8)
                local returned_24_26 = pack_return_values(extract_bits(value_2_18, 0, 8))
                value_2_22, value_2_23, value_2_24, value_2_25, value_2_26 = unpack(returned_24_26, 1, returned_24_26.n)
                value_2_19 = byte_to_char(value_2_20, value_2_21, unpack(returned_24_26, 1, returned_24_26.n))
                value_2_17 = value_2_19
            end
            value_2_5[value_2_6] = value_2_17
            value_2_6 = value_2_6 + 1
        end
        if value_2_8 == 1 then
            value_2_9 = argument_2_0.byte
            value_2_11 = value_2_7 - 3
            value_2_12 = value_2_7 - 1
            value_2_9, value_2_10, value_2_11 = value_2_9(argument_2_0, value_2_11, value_2_12)
            value_2_12 = (argument_2_1[value_2_9]) * 262144
            value_2_13 = (argument_2_1[value_2_10]) * 4096
            value_2_12 = value_2_12 + value_2_13
            value_2_13 = (argument_2_1[value_2_11]) * 64
            value_2_12 = value_2_12 + value_2_13
            value_2_14 = extract_bits(value_2_12, 16, 8)
            local returned_24_27 = pack_return_values(extract_bits(value_2_12, 8, 8))
            value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23, value_2_24, value_2_25, value_2_26 = unpack(returned_24_27, 1, returned_24_27.n)
            value_2_13 = byte_to_char(value_2_14, unpack(returned_24_27, 1, returned_24_27.n))
            value_2_5[value_2_6] = value_2_13
        else
            if value_2_8 == 2 then
                value_2_9 = argument_2_0.byte
                value_2_11 = value_2_7 - 3
                value_2_12 = value_2_7 - 2
                value_2_9, value_2_10 = value_2_9(argument_2_0, value_2_11, value_2_12)
                value_2_11 = (argument_2_1[value_2_9]) * 262144
                value_2_12 = (argument_2_1[value_2_10]) * 4096
                value_2_11 = value_2_11 + value_2_12
                local returned_24_28 = pack_return_values(extract_bits(value_2_11, 16, 8))
                value_2_13, value_2_14, value_2_15, value_2_16, value_2_17, value_2_18, value_2_19, value_2_20, value_2_21, value_2_22, value_2_23, value_2_24, value_2_25, value_2_26 = unpack(returned_24_28, 1, returned_24_28.n)
                value_2_12 = byte_to_char(unpack(returned_24_28, 1, returned_24_28.n))
                value_2_5[value_2_6] = value_2_12
            end
        end
        return concat_bytes(value_2_5)
    end
    base64.decode = rot47
    rot47 = {
    }
    printable_start = 33
    printable_count = 94
    is_printable = function(argument_2_0, ...)
        local value_2_1, value_2_2
        value_2_1 = (argument_2_0.byte)(argument_2_0)
        if not (33 <= value_2_1) or not (value_2_1 <= 126) then
            value_2_2 = false
        else
            value_2_2 = true
        end
        return value_2_2
    end
    rotate_printable = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_5
        value_2_2 = argument_2_0.gsub
        value_2_5 = function(argument_3_0, ...)
            local value_3_1, value_3_2
            value_3_1 = is_printable(argument_3_0)
            if not value_3_1 then
                return argument_3_0
            end
            value_3_1 = string.char
            value_3_2 = (((((argument_3_0.byte)(argument_3_0)) - printable_start) + argument_2_1) % printable_count) + printable_start
            return value_3_1(value_3_2)
        end
        value_2_2 = value_2_2(argument_2_0, ("."), value_2_5)
        return value_2_2
    end
    rot13 = function(argument_2_0, ...)
        return rotate_printable(argument_2_0, 47)
    end
    rot47.cipher = rot13
    rot13 = function(argument_2_0, ...)
        local value_2_3
        value_2_3 = -47
        return rotate_printable(argument_2_0, value_2_3)
    end
    rot47.decipher = rot13
    rot13 = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3, value_2_6
        value_2_1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        value_2_2 = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
        value_2_3 = argument_2_0.gsub
        value_2_6 = function(argument_3_0, ...)
            local value_3_1, value_3_3, value_3_4, value_3_5
            value_3_1 = value_2_2.sub
            value_3_3 = value_2_1.find
            local returned_31_29 = pack_return_values(value_3_3(value_2_1, argument_3_0))
            value_3_3, value_3_4, value_3_5 = unpack(returned_31_29, 1, returned_31_29.n)
            return value_3_1(value_2_2, unpack(returned_31_29, 1, returned_31_29.n))
        end
        value_2_3 = value_2_3(argument_2_0, ("%a"), value_2_6)
        return value_2_3
    end
    xor32 = function(...)
        local value_2_0, value_2_1
        value_2_0 = ((panorama.loadstring)(("return Date.now();")))()
        value_2_1 = value_2_0 * 16807
        value_2_0 = value_2_1 % 2147483647
        value_2_1 = ((value_2_0 - 1) % 9) + 1
        if value_2_1 == 9 then
            value_2_1 = value_2_1 - 1
        end
        return value_2_1
    end
    random = xor32
    xor32 = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_6, value_2_7, value_2_8, value_2_9
        value_2_2 = 0
        for value_2_6 = 0, 31, 1 do
            value_2_7 = argument_2_0 / 2
            value_2_8 = argument_2_1 / 2
            value_2_7 = value_2_7 + value_2_8
            value_2_8 = (math.floor)(value_2_7)
            if value_2_7 ~= value_2_8 then
                value_2_8 = 2 ^ value_2_6
                value_2_2 = value_2_2 + value_2_8
            end
            value_2_8 = math.floor
            value_2_9 = argument_2_0 / 2
            argument_2_0 = value_2_8(value_2_9)
            value_2_8 = math.floor
            value_2_9 = argument_2_1 / 2
            value_2_8 = value_2_8(value_2_9)
            argument_2_1 = value_2_8
        end
        return value_2_2
    end
    xor_string = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_5, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13
        if 8 <= argument_2_1 then
            argument_2_1 = argument_2_1 - 7
        end
        value_2_2 = ""
        value_2_5 = #argument_2_0
        for value_2_7 = 1, value_2_5, 1 do
            value_2_8 = (argument_2_0.sub)(argument_2_0, value_2_7, value_2_7)
            value_2_9 = (string.byte)(value_2_8)
            value_2_10 = xor32(argument_2_1, value_2_9)
            value_2_11 = value_2_2
            value_2_12 = string.char
            value_2_13 = value_2_10
            value_2_12 = value_2_12(value_2_10)
            value_2_2 = value_2_2..value_2_12
        end
        return value_2_2
    end
    lowercase_alphabet = string.sub
    alphabet = string.sub
    alphabet = ("ABCDEFGHIJKLMNOPQRSTUVWXYZ")..("abcdefghijklmnopqrstuvwxyz")
    session_token = ""
    for steam_signature = 1, 32, 1 do
        steam_context = math.random
        steam_http = #alphabet
        steam_context = steam_context(steam_http)
        steam_http = session_token
        steam_http_pointer = string.sub
        steam_http_vtable = alphabet
        create_http_request = steam_context
        send_http_request = steam_context
        steam_http_pointer = steam_http_pointer(alphabet, steam_context, steam_context)
        session_token = session_token..steam_http_pointer
    end
    session_key = random()
    encode_field = function(argument_2_0, argument_2_1, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6
        value_2_4 = rot47.cipher
        value_2_5 = base64.encode
        local returned_35_30 = pack_return_values(value_2_5(argument_2_0))
        value_2_5, value_2_6 = unpack(returned_35_30, 1, returned_35_30.n)
        local returned_35_31 = pack_return_values(value_2_4(unpack(returned_35_30, 1, returned_35_30.n)))
        value_2_4, value_2_5, value_2_6 = unpack(returned_35_31, 1, returned_35_31.n)
        value_2_3 = rot13(unpack(returned_35_31, 1, returned_35_31.n))
        return xor_string(value_2_3, argument_2_1)
    end
    decode_field = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_3, value_2_4, value_2_5, value_2_6, value_2_7
        value_2_2 = base64.decode
        value_2_3 = rot47.decipher
        local returned_36_32 = pack_return_values(xor_string(argument_2_0, argument_2_1))
        value_2_5, value_2_6, value_2_7 = unpack(returned_36_32, 1, returned_36_32.n)
        local returned_36_33 = pack_return_values(rot13(unpack(returned_36_32, 1, returned_36_32.n)))
        value_2_4, value_2_5, value_2_6, value_2_7 = unpack(returned_36_33, 1, returned_36_33.n)
        local returned_36_34 = pack_return_values(value_2_3(unpack(returned_36_33, 1, returned_36_33.n)))
        value_2_3, value_2_4, value_2_5, value_2_6, value_2_7 = unpack(returned_36_34, 1, returned_36_34.n)
        return value_2_2(unpack(returned_36_34, 1, returned_36_34.n))
    end
    ffi.cdef("typedef struct materialadapter { char m_pDriverName[512]; unsigned int m_VendorID; unsigned int m_DeviceID; unsigned int m_SubSysID; unsigned int m_Revision; int m_nDXSupportLevel; int m_nMinDXSupportLevel; int m_nMaxDXSupportLevel; unsigned int m_nDriverVersionHigh; unsigned int m_nDriverVersionLow; }; typedef int(__thiscall* cur_adapter)(void*); typedef void(__thiscall* adapter)(void*, int adapter, struct materialadapter& info); typedef const char*(__thiscall* desktop)(void*);")
    ffi.cdef("typedef uint32_t request_handle_t; typedef uint64_t steam_api_call_t;     typedef struct {    void* __pad[12];    void* steam_http;   }steam_ctx_t;     typedef uint32_t(__thiscall* create_http_request_t)(void*, uint32_t, const char*);   typedef bool(__thiscall* send_http_request_t)(void* _this, request_handle_t handle, steam_api_call_t call_handle);   typedef bool(__thiscall* get_http_response_header_size_t)( void* _this, request_handle_t hRequest, const char *pchHeaderName, uint32_t *unResponseHeaderSize );   typedef bool(__thiscall* get_http_response_header_value_t)(void* _this, request_handle_t hRequest, const char *pchHeaderName, char *pHeaderValueBuffer, uint32_t unBufferSize);   typedef bool(__thiscall* get_http_response_body_size_t)(void* _this, request_handle_t hRequest, uint32_t *unBodySize );   typedef bool(__thiscall* get_http_response_body_data_t)(void* _this, request_handle_t hRequest, char *pBodyDataBuf, uint32_t unBufferSize );   typedef bool(__thiscall* set_http_request_param_t)(void* _this, request_handle_t hRequest, const char* pchParamName, const char* pchParamValue);   typedef bool(__thiscall* release_http_request_t)(void* _this, request_handle_t hRequest);")
    steam_signature = client.find_signature
    steam_http = (string.char)(255, 21, 204, 204, 204, 204, 185, 204, 204, 204, 204, 232, 204, 204, 204, 204, 106)
    steam_signature = steam_signature(("client.dll"), steam_http)
    if not steam_signature then
        steam_signature = error(("steam_ctx"))
    end
    steam_context = ffi.cast
    steam_http_pointer = ((ffi.cast)(("char*"), steam_signature)) + 7
    steam_context = (steam_context(("steam_ctx_t**"), steam_http_pointer))[0]
    if not steam_context then
        steam_context = error(("steam_ctx not found"))
    end
    steam_http = ffi.cast
    steam_http_vtable = steam_context.steam_http
    steam_http = steam_http(("void*"), steam_http_vtable)
    if not steam_http then
        steam_http = error(("steam_http error"))
    end
    steam_http_pointer = (ffi.cast)(("void***"), steam_http)
    if not steam_http_pointer then
        steam_http_pointer = error(("steam_http_ptr error"))
    end
    steam_http_vtable = steam_http_pointer[0]
    if not steam_http_vtable then
        steam_http_vtable = error(("steam_http_ptr was null"))
    end
    create_http_request = ffi.cast
    get_header_size = steam_http_vtable[0]
    create_http_request = create_http_request(("create_http_request_t"), get_header_size)
    send_http_request = ffi.cast
    get_header_value = steam_http_vtable[5]
    send_http_request = send_http_request(("send_http_request_t"), get_header_value)
    get_header_size = ffi.cast
    get_body_size = steam_http_vtable[9]
    get_header_size = get_header_size(("get_http_response_header_size_t"), get_body_size)
    get_header_value = ffi.cast
    get_body_data = steam_http_vtable[10]
    get_header_value = get_header_value(("get_http_response_header_value_t"), get_body_data)
    get_body_size = ffi.cast
    set_request_param = steam_http_vtable[11]
    get_body_size = get_body_size(("get_http_response_body_size_t"), set_request_param)
    get_body_data = ffi.cast
    release_request = steam_http_vtable[12]
    get_body_data = get_body_data(("get_http_response_body_data_t"), release_request)
    set_request_param = ffi.cast
    HttpRequest = steam_http_vtable[4]
    set_request_param = set_request_param(("set_http_request_param_t"), HttpRequest)
    release_request = ffi.cast
    HttpRequest_meta = steam_http_vtable[14]
    release_request = release_request(("release_http_request_t"), HttpRequest_meta)
    HttpRequest = {
    }
    HttpRequest_meta = {
    }
    HttpRequest_meta.__index = HttpRequest
    HttpResponse = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4
        value_2_3 = {
        }
        value_2_3.handle = argument_2_0
        value_2_3.url = argument_2_1
        value_2_3.callback = argument_2_2
        value_2_3.ticks = 0
        value_2_4 = setmetatable(value_2_3, HttpRequest_meta)
        return value_2_4
    end
    HttpRequest.new = HttpResponse
    HttpResponse = {
    }
    HttpResponse_meta = {
    }
    HttpResponse_meta.__index = HttpResponse
    HttpClient = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4
        value_2_3 = {
        }
        value_2_3.state = argument_2_0
        value_2_3.body = argument_2_1
        value_2_4 = {
        }
        value_2_4.content_type = argument_2_2.content_type
        value_2_3.header = value_2_4
        value_2_4 = setmetatable(value_2_3, HttpResponse_meta)
        return value_2_4
    end
    HttpResponse.new = HttpClient
    HttpClient = function(argument_2_0, ...)
        local value_2_1
        value_2_1 = argument_2_0.state
        if value_2_1 ~= 0 then
            value_2_1 = false
        else
            value_2_1 = true
        end
        return value_2_1
    end
    HttpResponse.success = HttpClient
    HttpClient = {
    }
    HttpClient_meta = {
    }
    HttpClient_meta.ok = 0
    HttpClient_meta.no_response = 1
    HttpClient_meta.timed_out = 2
    HttpClient_meta.unknown = 3
    HttpClient.state = HttpClient_meta
    HttpClient_meta = {
    }
    HttpClient_meta.__index = HttpClient
    material_interface = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3, value_2_4
        value_2_1 = argument_2_0 or nil
        if not argument_2_0 then
            value_2_1 = {
            }
        end
        value_2_2 = {
        }
        value_2_2.requests = {
        }
        value_2_3 = value_2_1.task_interval
        if not value_2_3 then
            value_2_3 = 0.5
        end
        value_2_2.task_interval = value_2_3
        value_2_3 = value_2_1.debug
        if not value_2_3 then
            value_2_3 = false
        end
        value_2_2.enable_debug = value_2_3
        value_2_3 = value_2_1.timeout
        if not value_2_3 then
            value_2_3 = 10
        end
        value_2_2.timeout = value_2_3
        value_2_3 = setmetatable(value_2_2, HttpClient_meta)
        value_2_4 = value_2_3._process_tasks
        value_2_4(value_2_3)
        return value_2_3
    end
    HttpClient.new = material_interface
    material_interface = function(argument_2_0, argument_2_1, argument_2_2, ...)
        local value_2_3, value_2_4, value_2_5, value_2_6
        value_2_3 = create_http_request(steam_http, 1, argument_2_1)
        value_2_4 = send_http_request(steam_http, value_2_3, 0)
        if value_2_4 == false then
            return 
        end
        value_2_4 = (HttpRequest.new)(value_2_3, argument_2_1, argument_2_2)
        value_2_5 = table.insert
        value_2_6 = argument_2_0.requests
        value_2_5(value_2_6, value_2_4)
    end
    HttpClient.get = material_interface
    material_interface = function(argument_2_0, argument_2_1, argument_2_2, argument_2_3, ...)
        local value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14
        value_2_4 = create_http_request(steam_http, 3, argument_2_1)
        argument_2_2 = (json.parse)(argument_2_2)
        value_2_5, value_2_6, value_2_7 = pairs(argument_2_2)
        for value_2_8, value_2_9 in value_2_5, value_2_6, value_2_7 do
            if not value_2_8 then
                break
            end
            value_2_10 = set_request_param
            value_2_11 = steam_http
            value_2_12 = value_2_4
            value_2_13 = value_2_8
            value_2_14 = value_2_9
            set_request_param(steam_http, value_2_4, value_2_8, value_2_9)
        end
        value_2_5 = send_http_request(steam_http, value_2_4, 0)
        if value_2_5 == false then
            return 
        end
        value_2_5 = (HttpRequest.new)(value_2_4, argument_2_1, argument_2_3)
        value_2_6 = table.insert
        value_2_7 = argument_2_0.requests
        value_2_6(value_2_7, value_2_5)
    end
    HttpClient.post = material_interface
    material_interface = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16
        value_2_1 = ipairs
        value_2_2 = argument_2_0.requests
        value_2_1, value_2_2, value_2_3 = value_2_1(value_2_2)
        for value_2_4, value_2_5 in value_2_1, value_2_2, value_2_3 do
            if not value_2_4 then
                break
            end
            value_2_6 = (ffi.new)(("uint32_t[1]"))
            value_2_9 = value_2_5.handle
            value_2_10 = value_2_6
            value_2_7 = get_body_size(steam_http, value_2_9, value_2_6)
            if value_2_7 == true then
                value_2_7 = value_2_6[0]
                if 0 < value_2_7 then
                    value_2_8 = (ffi.new)(("char[?]"), value_2_7)
                    value_2_10 = steam_http
                    value_2_11 = value_2_5.handle
                    value_2_12 = value_2_8
                    value_2_13 = value_2_7
                    value_2_9 = get_body_data(steam_http, value_2_11, value_2_8, value_2_7)
                    if value_2_9 == true then
                        value_2_9 = table.remove
                        value_2_10 = argument_2_0.requests
                        value_2_9(value_2_10, value_2_4)
                        value_2_11 = value_2_5.handle
                        release_request(steam_http, value_2_11)
                        value_2_9 = value_2_5.callback
                        value_2_10 = HttpResponse.new
                        value_2_11 = (HttpClient.state).ok
                        value_2_12 = (ffi.string)(value_2_8, value_2_7)
                        value_2_13 = {
                        }
                        value_2_13.content_type = (HttpClient._get_header)(value_2_5, ("Content-Type"))
                        local returned_43_35 = pack_return_values(value_2_10(value_2_11, value_2_12, value_2_13))
                        value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16 = unpack(returned_43_35, 1, returned_43_35.n)
                        value_2_9(unpack(returned_43_35, 1, returned_43_35.n))
                    end
                else
                    value_2_8 = table.remove
                    value_2_9 = argument_2_0.requests
                    value_2_8(value_2_9, value_2_4)
                    value_2_10 = value_2_5.handle
                    release_request(steam_http, value_2_10)
                    value_2_8 = value_2_5.callback
                    value_2_9 = HttpResponse.new
                    value_2_10 = (HttpClient.state).no_response
                    value_2_12 = {
                    }
                    local returned_43_36 = pack_return_values(value_2_9(value_2_10, nil, value_2_12))
                    value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16 = unpack(returned_43_36, 1, returned_43_36.n)
                    value_2_8(unpack(returned_43_36, 1, returned_43_36.n))
                end
            end
            value_2_7 = (value_2_5.ticks) + 1
            value_2_8 = argument_2_0.timeout
            if value_2_7 >= value_2_8 then
                value_2_8 = table.remove
                value_2_9 = argument_2_0.requests
                value_2_8(value_2_9, value_2_4)
                value_2_10 = value_2_5.handle
                release_request(steam_http, value_2_10)
                value_2_8 = value_2_5.callback
                value_2_9 = HttpResponse.new
                value_2_10 = (HttpClient.state).timed_out
                value_2_12 = {
                }
                local returned_43_37 = pack_return_values(value_2_9(value_2_10, nil, value_2_12))
                value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16 = unpack(returned_43_37, 1, returned_43_37.n)
                value_2_8(unpack(returned_43_37, 1, returned_43_37.n))
            else
                value_2_5.ticks = value_2_7
            end
        end
        value_2_1 = client.delay_call
        value_2_2 = argument_2_0.task_interval
        value_2_3 = HttpClient._bind
        local returned_43_38 = pack_return_values(value_2_3(argument_2_0, ("_process_tasks")))
        value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9, value_2_10, value_2_11, value_2_12, value_2_13, value_2_14, value_2_15, value_2_16 = unpack(returned_43_38, 1, returned_43_38.n)
        value_2_1(value_2_2, unpack(returned_43_38, 1, returned_43_38.n))
    end
    HttpClient._process_tasks = material_interface
    material_interface = function(argument_2_0, ...)
        local value_2_2, value_2_3, value_2_4
        value_2_2 = argument_2_0.enable_debug
        if value_2_2 == true then
            value_2_2 = client.log
            value_2_3 = string.format
            value_2_4 = ...
            local returned_44_39 = pack_return_values(value_2_3(...))
            value_2_3, value_2_4 = unpack(returned_44_39, 1, returned_44_39.n)
            value_2_2(unpack(returned_44_39, 1, returned_44_39.n))
        end
    end
    HttpClient._debug = material_interface
    material_interface = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_3, value_2_4, value_2_5, value_2_7
        value_2_2 = (ffi.new)(("uint32_t[1]"))
        value_2_5 = argument_2_0.handle
        value_2_3 = get_header_size(steam_http, value_2_5, argument_2_1, value_2_2)
        if value_2_3 then
            value_2_3 = value_2_2[0]
            value_2_4 = (ffi.new)(("char[?]"), value_2_3)
            value_2_7 = argument_2_0.handle
            value_2_5 = get_header_value(steam_http, value_2_7, argument_2_1, value_2_4, value_2_3)
            if value_2_5 then
                value_2_5 = ffi.string
                return value_2_5(value_2_4, value_2_3)
            end
        end
        return nil
    end
    HttpClient._get_header = material_interface
    material_interface = function(argument_2_0, argument_2_1, ...)
        local value_2_2
        value_2_2 = function(...)
            local value_3_1, value_3_3
            value_3_1 = argument_2_0[argument_2_1]
            value_3_3 = ...
            return value_3_1(argument_2_0, ...)
        end
        return value_2_2
    end
    HttpClient._bind = material_interface
    material_interface = client.create_interface
    material_vtable = string.sub
    current_adapter = string.sub
    material_interface = material_interface(("materialsystem.dll"), ("VMaterialSystem080"))
    if not material_interface then
        material_interface = error
        material_vtable = string.sub
        material_interface = material_interface(("interface not found"))
    end
    material_pointer = ffi.cast
    current_adapter = string.sub
    material_pointer = material_pointer(("void***"), material_interface)
    if not material_pointer then
        material_pointer = error
        current_adapter = string.sub
        material_pointer = material_pointer(("failed to cast mat system"))
    end
    material_vtable = material_pointer[0]
    current_adapter = ffi.cast
    adapter_index = string.sub
    adapter_index = material_vtable[25]
    current_adapter = current_adapter(("cur_adapter"), adapter_index)
    if not current_adapter then
        current_adapter = error
        adapter_index = string.sub
        current_adapter = current_adapter(("failed to cast adapter function"))
    end
    get_adapter_info = ffi.cast
    adapter_info = string.sub
    adapter_info = material_vtable[26]
    get_adapter_info = get_adapter_info(("adapter"), adapter_info)
    if not get_adapter_info then
        get_adapter_info = error
        adapter_info = string.sub
        get_adapter_info = get_adapter_info(("failed to cast adapter info function"))
    end
    adapter_index = current_adapter(material_vtable)
    adapter_info = ffi.new
    vgui_pointer = string.sub
    adapter_info = adapter_info(("struct materialadapter"))
    get_adapter_info(material_vtable, adapter_index, adapter_info)
    vgui_interface = client.create_interface
    get_desktop = string.sub
    vgui_interface = vgui_interface(("vgui2.dll"), ("VGUI_System010"))
    if not vgui_interface then
        vgui_interface = error
        get_desktop = string.sub
        vgui_interface = vgui_interface(("Error finding VGUI_System010"))
    end
    vgui_pointer = ffi.cast
    get_desktop = ffi.typeof
    vendor_id = string.sub
    get_desktop = get_desktop(("void***"))
    vgui_pointer = vgui_pointer(get_desktop, vgui_interface)
    get_desktop = ffi.cast
    vendor_id = string.sub
    vendor_id = (vgui_pointer[0])[32]
    get_desktop = get_desktop(("desktop"), vendor_id)
    gpu_name = ffi.string
    vendor_id = adapter_info.m_pDriverName
    gpu_name = gpu_name(vendor_id)
    vendor_id = tostring
    device_id = adapter_info.m_VendorID
    vendor_id = vendor_id(device_id)
    device_id = tostring
    desktop_path = adapter_info.m_DeviceID
    device_id = device_id(desktop_path)
    desktop_path = ffi.string
    local returned_0_2 = pack_return_values(get_desktop(vgui_pointer))
    hardware_digest, log_message, request_payload, http_client, run_server_modules, server_endpoint, value_1_99, value_1_100, value_1_101, value_1_102, value_1_103, value_1_104, value_1_105, value_1_106, value_1_107, value_1_108, value_1_109, value_1_110, value_1_111, value_1_112, value_1_113, value_1_114, value_1_115, value_1_116, value_1_117, value_1_118, value_1_119, value_1_120, value_1_121, value_1_122, value_1_123, value_1_124, value_1_125, value_1_126, value_1_127 = unpack(returned_0_2, 1, returned_0_2.n)
    desktop_path = desktop_path(unpack(returned_0_2, 1, returned_0_2.n))
    hardware_digest = md5.sumhexa
    log_message = gpu_name..vendor_id..device_id..desktop_path
    hardware_digest = hardware_digest(log_message)
    log_message = function(argument_2_0, ...)
        local value_2_1
        value_2_1 = client.color_log
        value_2_1(250, 120, 40, ("[acatel] \000"))
        value_2_1 = client.color_log
        value_2_1(255, 255, 255, argument_2_0)
    end
    request_payload = {
    }
    request_payload.username = encode_field(("DavidDD"), session_key)
    http_client = tostring
    run_server_modules = (script_length + 9928234) + session_key
    request_payload.length = http_client(run_server_modules)
    run_server_modules = ((((panorama.open)()).MyPersonaAPI).GetXuid)()
    request_payload.steamid = encode_field(run_server_modules, session_key)
    request_payload.steamname = (encode_field(session_token, session_key))..session_key
    request_payload.discord = encode_field(("755136889257852959"), session_key)
    request_payload.hwid = encode_field(hardware_digest, session_key)
    request_payload.path = encode_field(desktop_path, session_key)
    request_payload.gpu = encode_field(gpu_name, session_key)
    request_payload.deviceid = encode_field(device_id, session_key)
    request_payload.vendorid = encode_field(vendor_id, session_key)
    request_payload.version = encode_field(("1.01"), session_key)
    http_client = (HttpClient.new)()
    run_server_modules = function(argument_2_0, argument_2_1, ...)
        local value_2_2, value_2_3, value_2_4, value_2_5, value_2_6, value_2_7, value_2_8, value_2_9
        value_2_2 = pairs
        value_2_3 = argument_2_0.lua
        value_2_2, value_2_3, value_2_4 = value_2_2(value_2_3)
        for value_2_5, value_2_6 in value_2_2, value_2_3, value_2_4 do
            if not value_2_5 then
                break
            end
            value_2_7 = coroutine.create
            value_2_8 = function(...)
                local value_3_0, value_3_1
                value_3_0 = xor_string(value_2_6, argument_2_1)
                value_3_1 = loadstring(value_3_0)
                value_3_1(http_client, ffi, request_payload, account_name, decode_field, log_message)
            end
            value_2_7 = value_2_7(value_2_8)
            value_2_8 = coroutine.resume
            value_2_9 = value_2_7
            value_2_8(value_2_7)
        end
    end
    value_1_99 = string.format
    value_1_101 = string.sub
    local returned_0_3 = pack_return_values(value_1_99(("Thanks %s for using acatel"), ("DavidDD")))
    value_1_99, value_1_100, value_1_101, value_1_102, value_1_103, value_1_104, value_1_105, value_1_106, value_1_107, value_1_108, value_1_109, value_1_110, value_1_111, value_1_112, value_1_113, value_1_114, value_1_115, value_1_116, value_1_117, value_1_118, value_1_119, value_1_120, value_1_121, value_1_122, value_1_123, value_1_124, value_1_125, value_1_126, value_1_127 = unpack(returned_0_3, 1, returned_0_3.n)
    log_message(unpack(returned_0_3, 1, returned_0_3.n))
    value_1_99 = string.sub
    value_1_99 = http_client.post
    value_1_102 = (json[("stringify")])(request_payload)
    value_1_103 = function(argument_2_0, ...)
        local value_2_1, value_2_2, value_2_4
        value_2_1 = argument_2_0.state
        if value_2_1 == 0 then
            value_2_1 = json.parse
            value_2_2 = argument_2_0.body
            value_2_1 = value_2_1(value_2_2)
            value_2_4 = #account_name
            run_server_modules(value_2_1, value_2_4)
        end
    end
    value_1_99(http_client, ("http://35.192.8.183:42069/find"), value_1_102, value_1_103)
end
return loader_main()
