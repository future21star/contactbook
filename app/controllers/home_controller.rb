require 'roo'

class HomeController < ApplicationController
  @@new_pos = []
  @@download = []
  @@params = []
  @@prs = []
  @@break_pos = 0
  @@step_new_pos = []
  @@step_unpushed_items = []
  @@receipt_id = -1
  @@receipt_line = -1
  
  def home
  end

  def upload_receipts
    @@params = params
    @@new_pos = []
    @@download = []
    @@params = []
    @@prs = []
    @@break_pos = 0
    @@step_new_pos = []
    @@step_unpushed_items = []
    @@receipt_id = -1
    @@receipt_line = -1
    
    xlsx = open_spreadsheet(params[:file])
    File.open("public/prs.xlsx","wb") do |f|
      f.write(params[:file].read)
    end

    #debugger
    #InvoiceMailer.send_pr(params[:email], params[:file]).deliver

    info = xlsx.sheets.last
    keys= []
    prs_temp = []
    prs_temp_count = 0
    xlsx.each_with_pagename do |name, sheet|
      prs_temp_count = sheet.column(1).length - 1
      keys = sheet.row(1)
      (2..prs_temp_count+1).each do |row_num|
        row = sheet.row(row_num)
        col_num = 0
        pr = {}
        row.each do |field|
          pr[keys[col_num]] = field
          col_num+=1
        end
        prs_temp.push(pr)
      end
    end

    # debugger
    # Background.perform_async(prs_temp)
    item_id_fields = ["item_lookup", "item_id", "Item_#", "UPC", "UPC code", "item", "Item #"]
    item_id_varies_fields = ["New Jigu Lookup", "Kum Kang lookup", "Midway Lookup", "Andy's Lookup"]
    order_id_fields = ["order_id", "PO #", "Num", "ponum", "PO#", "No_"]
    qty_fields = ["qy", "ORDER_QTY", "PO Line Qty", "QTY", "qty", "qtyshp", "PO_Qty", "qtyshp", "Qty", "Quantity (Base)", "qtyshp", "PO Line Qty"]

    vendor_items = ""
    data = File.read(Rails.root.join("public","vendor_items.csv"))
    CSV2JSON.parse(data, vendor_items)
    vendor_items = JSON.parse(vendor_items)
    
   #  csv_string = @@params[:datafile].read
   #  debugger
   #  xlsx = Roo::Spreadsheet.open(csv_string, extension: :xlsx)
    # receipts = ""
    # CSV2JSON.parse(csv_string, receipts)
    # prs_temp_temp = JSON.parse(receipts)
    prs = []
    #debugger
    for pr_temp in prs_temp
      pr = {}
      for item_id_field in item_id_fields
        pr["item_lookup"] = pr_temp[item_id_field] if pr_temp[item_id_field]!=nil
      end
      for item_id_varies_field in item_id_varies_fields
        if pr_temp[item_id_varies_field]!=nil
          vender_str = vendor_str.slice![0..item_id_varies_field.length - 7]
          for vendor_item in vendor_items
            if vendor_item["VENDOR"] == vendor_str && vendor_item["Item #"] == pr_temp[item_id_variesfield]
              pr["item_lookup"] = vendor_item["Vendor Item #"]
              break
            end
          end
        end
      end
      for order_id_field in order_id_fields
        pr["order_id"] = pr_temp[order_id_field] if pr_temp[order_id_field]!=nil
      end
      for qty_field in qty_fields
        pr["qty"] = pr_temp[qty_field] if pr_temp[qty_field]!=nil
      end
      if pr["item_lookup"] != nil && pr["order_id"] != nil && pr["qty"] != nil
        prs.push(pr)
      end
    end

    springboard = Springboard::Client.new(
      'https://bsw.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI5Yjc0Y2M1ZC01ZmFkLTQ1YjItYWRiNS02NTFmNDIyOTEwM2EiLCJpYXQiOjE0NzAzMTA5OTQsInN1YiI6MTAwMDA3LCJhdWQiOjIxNTJ9.LV_VCOaiXAfd03v4Lo71B-N8B9b90HaeZMvivfqHMk0')

    springboard_test = Springboard::Client.new(
      'https://bsw-test.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJmNTMwMmUxOS04YTdhLTQ0M2EtOTM5ZC1jMWMxYWI0NDc3Y2EiLCJpYXQiOjE0NjUxMjY0NTIsInN1YiI6MTAwMDE3LCJhdWQiOjIzODR9.y8VIMOKmVP0-GCYGe1KbSSz2dEQG_79e8wTpa3sa-3g')
    new_receipt = springboard["purchasing/receipts"]
    response = new_receipt.post :order_id => prs[0]["order_id"]
    line_url = response.headers['Location'][4..-1] + "/lines"
    
    @@receipt_id = response.headers['Location'][25..-1]
    @@receipt_line = springboard[line_url]
    @@prs = prs
    @@count = prs.length / 2
    render 'home/loading'
  end

  def upload_receipts_ajax_part_0

    which_part = params[:which_part]
    prs = @@prs
    #debugger  
    springboard = Springboard::Client.new(
      'https://bsw.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI5Yjc0Y2M1ZC01ZmFkLTQ1YjItYWRiNS02NTFmNDIyOTEwM2EiLCJpYXQiOjE0NzAzMTA5OTQsInN1YiI6MTAwMDA3LCJhdWQiOjIxNTJ9.LV_VCOaiXAfd03v4Lo71B-N8B9b90HaeZMvivfqHMk0')

    springboard_test = Springboard::Client.new(
      'https://bsw-test.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJmNTMwMmUxOS04YTdhLTQ0M2EtOTM5ZC1jMWMxYWI0NDc3Y2EiLCJpYXQiOjE0NjUxMjY0NTIsInN1YiI6MTAwMDE3LCJhdWQiOjIzODR9.y8VIMOKmVP0-GCYGe1KbSSz2dEQG_79e8wTpa3sa-3g')

    receipt_id = @@receipt_id
    receipt_line = @@receipt_line
    @new_pos = []
    @unpushed_items = []
    debugger
    for pr in prs
      # next if which_part == "0" && prs.index(pr) > prs.length / 2
      # next if which_part == "1" && prs.index(pr) < prs.length / 2

      item_lookup = pr["item_lookup"].to_s
      order_id = pr["order_id"]
      qty = pr["qty"]
      item_id = nil
      
      order_line_url = "purchasing/orders/" + order_id.to_s + "/lines"
      get_order = springboard[order_line_url]
      response = get_order.query(per_page: 100).get.body[:results]

      for order_line in response
        #puts "existing upc:" + order_line[:item_custom][:upc].to_s.downcase + "    " + "new item_id:" + item_lookup.to_s.downcase
        if order_line[:item_custom][:upc].to_s.downcase == item_lookup.to_s.downcase
          item_id = order_line[:item_id]
          break
        end
      end 
      if item_id == nil
        qty_temp = qty.to_s + "(unauthorized)"
        new_order_line = springboard["purchasing/orders/" + order_id.to_s + "/lines"]

        #puts "Item lookup:::::::::::::::" + item_lookup.to_s
        new_po_line = new_order_line.post :item_lookup => item_lookup.to_s, :order_id => order_id.to_s, :qty => qty
        #debugger
        if new_po_line.headers['Location']
          #item_id = new_po_line[:item_lookup]
          item_lookup_temp = item_lookup.to_s + "unauthorized"
          new_po = {:item_id => item_lookup.to_s, :order_id => order_id, :qty => qty_temp}
          @new_pos.push(new_po)
        end
      end
      response = receipt_line.post :item_lookup => item_lookup.to_s, :qty => qty, :receipt_id => receipt_id unless item_lookup.to_s == nil
      unless response.headers['Location'].present?      
        unpushed_item = {:item_id => item_lookup.to_s, :order_id => order_id, :qty => qty}
        @unpushed_items.push(unpushed_item)
      end
      #@@prs.delete(pr)
      #puts "----------------------------------------------"
    end
    #render template: 'home/success'
    debugger
    @@step_new_pos += @new_pos
    @@step_unpushed_items += @unpushed_items
    @@download = @@step_new_pos + @@step_unpushed_items

    @final_new_pos = @@step_new_pos
    @final_unpushed_items = @@step_unpushed_items

    render template: 'home/success'

    # @posts = Post.all
    # respond_to do | format |  
    #   format.html # index.html.erb
    #   format.json { render :json => @posts }
    #   format.xlsx {
    #     xlsx_package = Post.to_xlsx
    #     begin 
    #       temp = Tempfile.new("posts.xlsx") 
    #       xlsx_package.serialize temp.path
    #       send_file temp.path, :filename => "posts.xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    #     ensure
    #       temp.close 
    #       temp.unlink
    #     end
    #   }
    # end  
  end

  def upload_receipts_ajax_part_1

    which_part = params[:which_part]
    prs = @@prs
    #debugger  
    springboard = Springboard::Client.new(
      'https://bsw.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI5Yjc0Y2M1ZC01ZmFkLTQ1YjItYWRiNS02NTFmNDIyOTEwM2EiLCJpYXQiOjE0NzAzMTA5OTQsInN1YiI6MTAwMDA3LCJhdWQiOjIxNTJ9.LV_VCOaiXAfd03v4Lo71B-N8B9b90HaeZMvivfqHMk0')

    springboard_test = Springboard::Client.new(
      'https://bsw-test.myspringboard.us/api',
      token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJmNTMwMmUxOS04YTdhLTQ0M2EtOTM5ZC1jMWMxYWI0NDc3Y2EiLCJpYXQiOjE0NjUxMjY0NTIsInN1YiI6MTAwMDE3LCJhdWQiOjIzODR9.y8VIMOKmVP0-GCYGe1KbSSz2dEQG_79e8wTpa3sa-3g')

    receipt_id = @@receipt_id
    receipt_line = @@receipt_line
    @new_pos = []
    @unpushed_items = []
    debugger
    for pr in prs
      # next if which_part == "0" && prs.index(pr) > prs.length / 2
      # next if which_part == "1" && prs.index(pr) < prs.length / 2

      item_lookup = pr["item_lookup"].to_s
      order_id = pr["order_id"]
      qty = pr["qty"]
      item_id = nil
      
      order_line_url = "purchasing/orders/" + order_id.to_s + "/lines"
      get_order = springboard[order_line_url]
      response = get_order.query(per_page: 100).get.body[:results]

      for order_line in response
        #puts "existing upc:" + order_line[:item_custom][:upc].to_s.downcase + "    " + "new item_id:" + item_lookup.to_s.downcase
        if order_line[:item_custom][:upc].to_s.downcase == item_lookup.to_s.downcase
          item_id = order_line[:item_id]
          break
        end
      end 
      if item_id == nil
        qty_temp = qty.to_s + "(unauthorized)"
        new_order_line = springboard["purchasing/orders/" + order_id.to_s + "/lines"]

        #puts "Item lookup:::::::::::::::" + item_lookup.to_s
        new_po_line = new_order_line.post :item_lookup => item_lookup.to_s, :order_id => order_id.to_s, :qty => qty
        #debugger
        if new_po_line.headers['Location']
          #item_id = new_po_line[:item_lookup]
          item_lookup_temp = item_lookup.to_s + "unauthorized"
          new_po = {:item_id => item_lookup.to_s, :order_id => order_id, :qty => qty_temp}
          @new_pos.push(new_po)
        end
      end
      response = receipt_line.post :item_lookup => item_lookup.to_s, :qty => qty, :receipt_id => receipt_id unless item_lookup.to_s == nil
      unless response.headers['Location'].present?      
        unpushed_item = {:item_id => item_lookup.to_s, :order_id => order_id, :qty => qty}
        @unpushed_items.push(unpushed_item)
      end
      #@@prs.delete(pr)
      #puts "----------------------------------------------"
    end
    #render template: 'home/success'
    #debugger
    @@step_new_pos += @new_pos
    @@step_unpushed_items += @unpushed_items
    @@download = @@step_new_pos + @@step_unpushed_items

    @final_new_pos = @@step_new_pos
    @final_unpushed_items = @@step_unpushed_items

    render template: 'home/success'

    # @posts = Post.all
    # respond_to do | format |  
    #   format.html # index.html.erb
    #   format.json { render :json => @posts }
    #   format.xlsx {
    #     xlsx_package = Post.to_xlsx
    #     begin 
    #       temp = Tempfile.new("posts.xlsx") 
    #       xlsx_package.serialize temp.path
    #       send_file temp.path, :filename => "posts.xlsx", :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    #     ensure
    #       temp.close 
    #       temp.unlink
    #     end
    #   }
    # end  
  end

  def success

  end

  def download
    csv_string = CSV.generate do |csv|
      csv << ['Item#', 'Order#', 'Qty']
      @@download.each do |hash|
        csv << hash.values
      end
    end
    send_data(csv_string, :filename => "POs.csv")
  end

  private
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, nil, :ignore)
        when ".xls" then Roo::Spreadsheet.open(file.path)
        when ".xlsx" then Roo::Spreadsheet.open(file.path)
        else raise "Unknown file type: #{file.original_filename}"
      end
    end

    def self.to_csv(pos)

      CSV.generate do |csv|
        csv << ["item_id", "order_id", "qty"]
        pos.each do |po|
          csv << [po["item_id"], po["order_id"], po["qty"]]
        end
      end
    end
end
