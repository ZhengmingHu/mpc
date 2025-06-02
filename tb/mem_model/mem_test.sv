module memory_interface;
    // Import DPI-C functions with enable signals
    import "DPI-C" function void init_memory();
    import "DPI-C" function void write_memory(
        input int address, 
        input bit [254:0] data,
        input bit write_en
    );
    import "DPI-C" function void read_memory(
        input int address, 
        output bit [254:0] data,
        input bit read_en
    );
    
    // Initialize memory
    initial begin
        init_memory();
    end
    
    // Example usage with enable signals
    initial begin
        bit [254:0] test_data;
        bit [254:0] read_back;
        bit write_enable;
        bit read_enable;
        
        // Test 1: Write with enable
        test_data = 255'h1A2B3C4D5E6F7A8B9C0D1E2F3A4B5C6D7E8F9A0B1C2D3E4F5A6B7C8D9E0F1A2B3C4D;
        write_enable = 1'b1;
        write_memory(0, test_data, write_enable);
        
        // Read with enable
        read_enable = 1'b1;
        read_memory(0, read_back, read_enable);
        
        $display("Test 1 - Write Enabled:");
        $display("Written: %h", test_data);
        $display("Read back: %h", read_back);
        
        // Test 2: Write without enable
        test_data = 255'hDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF;
        write_enable = 1'b0;
        write_memory(0, test_data, write_enable);
        
        // Read without enable
        read_enable = 1'b0;
        read_memory(0, read_back, read_enable);
        
        $display("\nTest 2 - Write Disabled:");
        $display("Attempted write: %h", test_data);
        $display("Read back should be original value: %h", read_back);
        
        // Test 3: Read without enable but previous write with enable
        test_data = 255'h5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A;
        write_enable = 1'b1;
        write_memory(1023, test_data, write_enable);
        
        read_enable = 1'b0;
        read_memory(1023, read_back, read_enable);
        
        $display("\nTest 3 - Read Disabled:");
        $display("Written (enabled): %h", test_data);
        $display("Read back (disabled) should be zeros: %h", read_back);
    end
endmodule