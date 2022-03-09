class EventsController < ApplicationController
  before_action :authenticate_user!

  def index

  end
  
  def create_event

    #RSVP
    session[:e_title] = params[:e_title]
    $title_saved  = session[:e_title]

    session[:event_date] = params[:event_date]
    $event_date = session[:event_date]
    
    session[:event_tickets] = params[:event_tickets]
    $event_tickets = session[:event_tickets]

    session[:event_address] = params[:event_address]
    $event_address = session[:event_address]

    session[:event_image] = params[:event_image]
    $event_image = session[:event_image]

    session[:event_picture] = params[:event_picture]
    $event_pic = session[:event_picture]

    session[:event_picture_size_left] = params[:event_picture_size_left]
    $event_pic_size_left = session[:event_picture_size_left]

    session[:event_picture_size_right] = params[:event_picture_size_right]
    $event_pic_size_right = session[:event_picture_size_right] 

    session[:event_text] = params[:event_text]
    $event_txt = session[:event_text] 

  end

  def create_referral

        $reward = params[:reward]
        session[:reward] ||= params[:reward] 
    
        if $reward.to_s.length > 0
          flash[:notice] = "Referral reward updated!"
        end
  end
  
  # def import_new_spreadsheet
  #   if !params[:file]
  #     redirect_to root_path and return
  #   end
  #   event = Event.import(params[:file])
  #   puts(event.title)
  #   #redirect_to event_path(event)
  #   #event = Event.find_by(title: params[:event_title])
  #   @guests = $event.guests
  #   @guest_params = Guest.column_names
  # end

  def import_new_spreadsheet
    if !params[:file]
      redirect_to root_path and return
    end
    event = Event.import(params[:file])
    puts(event.title)
    redirect_to event_path(event)
  end
  
  def open_existed_spreadsheet
    event = Event.find_by(title: params[:event_title])
    
    $event_pic = session[:event_picture] #Grab picture from session
    $event_txt = session[:event_text] #Grab text from session

    $event_pic_size_left = session[:event_picture_size_left]
    $event_pic_size_right = session[:event_picture_size_right] 
    

    if !event
      flash[:notice] = "Cannot find the event #{params[:event_title]}."
      redirect_to root_path and return
    end
    # puts(event.title)
    redirect_to event_path(event)
    
  end

  #Seat Categories Code //////////////////
  def seat_categories
    redirect_to root_path and return
  end
  
  class SeatWiseRows
    attr_accessor :vip_seats
    attr_accessor :non_vip_seats
    attr_accessor :seat_category
    attr_accessor :total_seats
    attr_accessor :balance
    #attr_accessor :model_name
    
    def initialize(a, b, c, d, e)
      #@model_name = 'SeatWiseRows'
      @total_seats = a
      @vip_seats = b
      @non_vip_seats = c
      @seat_category = d
      @balance = e
    end
  end
 #^Seat Categories Code //////////////////
  
 def show
  @event = Event.find(1)
  $event_pic = $event_pic.to_s #new


  @seat_types = SeatingType.all
  @guests = @event.guests
    @guest_params = Guest.column_names.map(&:clone)
    @cat = []
    #seat category additions
    @bo_seat_wise_split = {}
    @vip_seat_wise_split = {}
    @seat_category_set = Set.new
    @total_seat_wise_split = []
    @seat_type_split = []
    #end seat category additions

    
    fixed_params = ['id', 'booking_status', 'total_booked_num']
    fixed_params.each do |fixed_param|
      @guest_params.delete(fixed_param)
    end
    @customers = @event.box_office_customers.split('#row#').map{|row| row.split('#cell#')}

  @customers = @event.box_office_customers.split('#row#').map{|row| row.split('#cell#')}
  
  #new
  @customers[1..-1].each do |row|
    @seat_category_set.add?(row[9])
    
    if @bo_seat_wise_split.keys.include?(row[9]) == true
      @bo_seat_wise_split[row[9]] += row[24].to_i
    else
      @bo_seat_wise_split[row[9]] = row[24].to_i
    end
  end
  
  @guests.each do |guest|
    puts(guest)
    @seat_category_set.add?(guest[:seat_category])
    
    if @vip_seat_wise_split.keys.include?(guest[:seat_category]) == true
      @vip_seat_wise_split[guest[:seat_category]] += guest[:max_seats_num]    #change to guest[:total_booked_num]
    else
      @vip_seat_wise_split[guest[:seat_category]] = guest[:max_seats_num]     #change to guest[:total_booked_num]
    end
  end
  
  # @seat_category_set.each do |category_name|
  #   vip_seats = 0
  #   non_vip_seats = 0
  #   if @vip_seat_wise_split.keys.include?(category_name)
  #     vip_seats = @vip_seat_wise_split[category_name]
  #   end
    
    @seat_category_set.each do |category_name|
      vip_seats = 0
      non_vip_seats = 0
      if @vip_seat_wise_split.keys.include?(category_name)
        vip_seats = @vip_seat_wise_split[category_name]
      end
      if @bo_seat_wise_split.keys.include?(category_name)
        non_vip_seats = @bo_seat_wise_split[category_name]
      end
      
      total_seats = 500
      balance = total_seats - vip_seats.to_i - non_vip_seats.to_i
      hash = { total_seats: total_seats, vips_seats: vip_seats.to_i, non_vip_seats: non_vip_seats.to_i, category_name: category_name,balance: balance }
      
# {:bacon=>:protein, :apple=>:fruit}
      @cat.append(hash)
      newEntry = SeatWiseRows.new(total_seats, vip_seats, non_vip_seats, category_name, balance)
      @total_seat_wise_split.append(newEntry)
    if @bo_seat_wise_split.keys.include?(category_name)
      non_vip_seats = @bo_seat_wise_split[category_name]
    end
   
    total_seats = 500
    balance = total_seats - vip_seats.to_i - non_vip_seats.to_i
    newEntry = SeatWiseRows.new(total_seats, vip_seats, non_vip_seats, category_name, balance)
    @total_seat_wise_split.append(newEntry)
  end
  #new end
  #for @category in @cat
    #puts(@category[:vips_seats])
  #end
    @event.total_seats_guest = 0
    for guest in @guests
      
      if guest.total_booked_num!=nil
          @event.total_seats_guest += guest.total_booked_num
      end
    end
    @event.balance = @event.total_seats - @event.total_seats_box_office - @event.total_seats_guest
    
    string_error = ""
    if params[:reconcile].nil?
      @seat_types.each do |seat_type|
        @seat_type_split.append(seat_type)
      end
      
      for @category in @cat
        for seat_type in @seat_type_split
          if seat_type[:seat_category] == @category[:category_name]
            if @category[:vip_seats].nil?
              @category[:vip_seats] = 0
            end
            seat_type[:vip_seat_count] = @category[:vips_seats]
            #print(@category[:vip_seats])
          end
        end
      end
    else
      @seat_types.each do |seat_type|
        @seat_type_split.append(seat_type)
      end
      for @category in @cat
        found = 0
        for seat_type in @seat_type_split
          if seat_type[:seat_category] == @category[:category_name]
            found = 1
            if @category[:vip_seats].nil?
              @category[:vip_seats] = 0
            end
            balance_seat = seat_type[:total_seat_count] - @category[:vip_seats] - @category[:non_vip_seats]
            seat_type[:balance_seats] = balance_seat
            seat_type[:box_office_seat_count] = @category[:non_vip_seats]
            seat_type[:vip_seat_count] = @category[:vips_seats]
            #print(@category[:vip_seats])
          end
        end
        if found == 0
          string_error  += @category[:category_name] + ", "
        end
      end
    end
    if string_error!= ""
      string_error += "is not in the database."
      puts(string_error)
      flash[:warning] = string_error
    end
end
  
  # def new
  #   @event = Event.new
  # end

  # def create
  #   @event = Event.new(event_params)

  #   if @event.save
  #     redirect_to event_path(@event)
  #   else
  #     render :new
  #   end
  # end
  
  
  # def edit
  #   @event = Event.find(params[:id])
  # end
  def reconcile
    @seat_type_split = []
    @seat_types = SeatingType.all
    @seat_types.each do |seat_type|
      #newEntry = SeatWiseNonExcelRows.new(total_seats, vip_seats, non_vip_seats, category_name, balance)
      @seat_type_split.append(seat_type)
    end
    redirect_to event_path(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      redirect_to @event
    else
      flash[:notice] = "Failed to update the event information."
      redirect_to @event
    end
  end
  
  # def destroy
  #   @event = Event.find(params[:id])
  #   @event.destroy

  #   redirect_to root_path
  # end
  
  private
    def event_params
      params.require(:event).permit(:title, :date, :total_seats, :total_seats_box_office, :total_seats_guest, :guests => [:type, :coordinates => []])
    end
      

end