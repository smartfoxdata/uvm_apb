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

virtual class apb_base_seq extends uvm_sequence #(apb_txn);
   protected int id;

   function new (string name="apb_base_seq");
      super.new(name);
   endfunction // new

   task pre_start ();
      apb_sqr sqr;
      super.pre_start();
      $cast(sqr, m_sequencer);
      id = sqr.id;      
   endtask // pre_start

endclass // apb_base_seq

class no_activity_seq extends apb_base_seq;
   `uvm_object_utils(no_activity_seq)
   
   function new(string name="no_activity_seq");
      super.new(name);
   endfunction // new

   virtual task body();
      `uvm_info("SEQ", "executing", UVM_LOW)
   endtask // body
			    
endclass // no_activity_seq

/* -----\/----- EXCLUDED -----\/-----
class random_seq extends apb_base_seq;
   `uvm_object_utils(random_seq)
   
   function new(string name="random_seq");
      super.new(name);
   endfunction // new

   virtual task body();
      apb_txn item;
      `uvm_info("SEQ", "executing...", UVM_LOW)
      `uvm_create(item)
      item.cycles = $urandom_range(1,5);
      item.data = $urandom();
      `uvm_send(item);
   endtask // body

endclass // random_seq

class directed_seq extends apb_base_seq;
   `uvm_object_utils(directed_seq)
   
   function new(string name="directed_seq");
      super.new(name);
   endfunction // new

   virtual task body();
      apb_txn item;
      `uvm_info("SEQ", "executing...", UVM_LOW)
      `uvm_create(item)
      item.cycles = 2;
      item.data = 8'hf;
      `uvm_send(item);
   endtask // body

endclass // directed_seq

class usevar_seq extends apb_base_seq;
   `uvm_object_utils(usevar_seq)
   
   function new(string name="usevar_seq");
      super.new(name);
   endfunction // new

   virtual task body();
      apb_txn item;
      `uvm_info("SEQ", "executing...", UVM_LOW)
      `uvm_info("SEQ", $sformatf("using id=%0hh from sequencer", id), UVM_LOW)
      `uvm_create(item)
      item.cycles = $urandom_range(1,5);
      item.data = id;
      `uvm_send(item);
   endtask // body

endclass // usevar_seq
 -----/\----- EXCLUDED -----/\----- */
