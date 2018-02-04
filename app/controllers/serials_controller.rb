class SerialsController < ApplicationController
  before_action :set_serial, only: [:show, :edit, :update, :destroy]

  # GET /serials
  # GET /serials.json
  def index
     @serials = Serial.all

  end

  # GET /serials/1
  # GET /serials/1.json
  def show
  end
  def tracked
    @serials = Serial.all.where(:tracked =>true)
  end
  # GET /serials/new
  def new
    @serial = Serial.new
  end

  # GET /serials/1/edit
  def edit
  end
  def track
    @serials = Serial.all
    @id=params[:id].to_i 
    @value=params[:value]
    @serials[@id].tracked=@value
    @serials[@id].save
  end
  def check
    @id=params[:id].to_i 
    if @id<0 then 
      system "rake serials_update:update_all"
    else
      system "rake serials_update:update_serial[#{@id}]"
    end
  end
  # POST /serials
  # POST /serials.json
  def create
    @serial = Serial.new(serial_params)

    respond_to do |format|
      if @serial.save
        format.html { redirect_to @serial, notice: 'Serial was successfully created.' }
        format.json { render :show, status: :created, location: @serial }
      else
        format.html { render :new }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /serials/1
  # PATCH/PUT /serials/1.json
  def update
    respond_to do |format|
      if @serial.update(serial_params)
        format.html { redirect_to @serial, notice: 'Serial was successfully updated.' }
        format.json { render :show, status: :ok, location: @serial }
      else
        format.html { render :edit }
        format.json { render json: @serial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /serials/1
  # DELETE /serials/1.json
  def destroy
    @serial.destroy
    respond_to do |format|
      format.html { redirect_to serials_url, notice: 'Serial was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  def add_serial
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_serial
      @serial = Serial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def serial_params
      params.require(:serial).permit(:name, :image, :serial_link, :about_short, :about_full, :tracked)
    end
end
