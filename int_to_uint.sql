/*
 * PG的hash函数返回的是个int值，将int转换为unsigned int
 * 输入：int
 * 输出：unsigned int
 */
CREATE OR REPLACE FUNCTION to_uint32(hash_value int)
RETURNS bigint
AS $$
DECLARE
    bit_value bit(32);
    single_bit int;
    result bigint := 0;
    bit_index int;
    count_index int := 31;
BEGIN
    -- 如果是正数或者0，直接返回
    IF hash_value >= 0 THEN
        RETURN hash_value;
    END IF;
    
    -- 先把int值转换为32位bit类型的值
    SELECT hash_value::bit(32) INTO bit_value;

    -- 把每个bit位取出来，组成1个数组
    -- 数组从0到31，分别是bit的最左位到最右位
    FOR bit_index in 0..31 LOOP
        -- 取出1位
        SELECT get_bit(bit_value,bit_index) INTO single_bit;
        -- 转换为十进制后的值（从高位开始算，因此第一位是2^31）
        SELECT (2^count_index)*single_bit + result INTO result;
        -- 更新计数器
        SELECT count_index - 1 INTO count_index;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql ;
