////////////////////////////////////////////////////////////////////////////////
//
// MIT License
//
// Copyright (c) 2017 Smartfox Data Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////


//TO DO: handle pready and pslverr

class apb_mr_drv extends uvm_driver #(apb_txn);
   protected virtual apb_if vif;
   protected int id;

   `uvm_component_utils_begin(apb_mr_drv)
      `uvm_field_int(id, UVM_DEFAULT)
   `uvm_component_utils_end

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
	`uvm_fatal("NOVIF", {"virtual interface must be set for: ",
			     get_full_name(), ".vif"});
   endfunction // build_phase

   virtual task run_phase (uvm_phase phase);
      fork
	 get_and_drive();
	 reset_signals();
      join
   endtask // run_phase

   virtual protected task get_and_drive();
      forever begin
	 @(posedge vif.pclk);
	 if (vif.presetn == 1'b0) begin
	    @(posedge vif.presetn);
	    @(posedge vif.pclk);
	 end
	 seq_item_port.get_next_item(req);
	 if (req.kind == apb_txn::READ) begin
	    req.data = 'hx;
	 end
	 `uvm_info("DRV", req.convert2string(), UVM_LOW)
	 case (req.kind)
	   apb_txn::READ: read(req.addr, req.data);
	   apb_txn::WRITE: write(req.addr, req.data);
	 endcase // case (req.kind)
	 seq_item_port.item_done();
      end
   endtask // get_and_drive

   virtual protected task reset_signals();
      forever begin
	 @(negedge vif.presetn);
	 vif.paddr <= 'h0;
	 vif.pwdata <= 'h0;
	 vif.psel <= 'b0;
	 vif.penable <= 'b0;
	 vif.pwrite <= 'b0;
	 vif.pclken <= 'b1;
      end
   endtask // reset_signals

   virtual protected task read(input  bit   [31:0] addr,
                               output logic [31:0] data);
      this.vif.paddr   <= addr;
      this.vif.pwrite  <= '0;
      this.vif.psel    <= '1;
      @ (posedge this.vif.pclk);
      this.vif.penable <= '1;
      @ (posedge this.vif.pclk);
      data = this.vif.prdata;
      this.vif.psel    <= '0;
      this.vif.penable <= '0;
   endtask: read

   virtual protected task write(input bit [31:0] addr,
                                input bit [31:0] data);
      this.vif.paddr   <= addr;
      this.vif.pwdata  <= data;
      this.vif.pwrite  <= '1;
      this.vif.psel    <= '1;
      @ (posedge this.vif.pclk);
      this.vif.penable <= '1;
      @ (posedge this.vif.pclk);
      this.vif.psel    <= '0;
      this.vif.penable <= '0;
   endtask: write
   
endclass // apb_mr_drv
