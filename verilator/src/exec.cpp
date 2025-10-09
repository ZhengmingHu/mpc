#include <common.h>
#include <opcode.h>
#include <sim.h>

template<size_t N>
VlWide<N> create_vlwide(std::initializer_list<uint32_t> values) {
   
    uint32_t a[N];
    std::copy(values.begin(), values.end(), a);
    
    VlWide<N> data;
    std::copy(std::rbegin(a), std::rend(a), std::begin(data.m_storage));
    return data;
}

void sim_exec() {
    
    sim_delay(2);

    top->u_channel_0_req_bus_valid = 1;

    top->u_channel_0_req_bus_op = LOAD;

    top->u_channel_0_req_bus_size = HALF;

    top->u_channel_0_req_bus_wdata = create_vlwide<4>({0x0, 0x0, 0x0, 0x0});
 
    top->u_channel_0_req_bus_addr = 0x80000000;

    top->u_channel_0_rsp_bus_ready = 1;

    sim_delay(2);

    top->u_channel_0_req_bus_valid = 0;
    
    top->u_channel_0_req_bus_op = 0;

    top->u_channel_0_req_bus_size = 0;

    top->u_channel_0_req_bus_addr = 0;

    sim_delay(200);


}

