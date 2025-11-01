# frozen_string_literal: true

# Example controller with authentication, authorization, and multi-tenancy
class ExampleModelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_example_model, only: %i[show edit update destroy]
  before_action -> { authorize @example_model || ExampleModel }

  # GET /example_models
  def index
    @example_models = policy_scope(ExampleModel)
                        .active
                        .page(params[:page])
                        .per(20)

    respond_to do |format|
      format.html
      format.json { render json: @example_models }
    end
  end

  # GET /example_models/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: @example_model }
    end
  end

  # GET /example_models/new
  def new
    @example_model = ExampleModel.new
  end

  # GET /example_models/:id/edit
  def edit
    # Rendered by view
  end

  # POST /example_models
  def create
    @example_model = Current.organization.example_models.new(example_model_params)

    if @example_model.save
      redirect_to @example_model, notice: t('controllers.example_models.create.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /example_models/:id
  def update
    if @example_model.update(example_model_params)
      redirect_to @example_model, notice: t('controllers.example_models.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /example_models/:id
  def destroy
    @example_model.destroy!
    redirect_to example_models_url, notice: t('controllers.example_models.destroy.success')
  end

  private

  def set_organization
    Current.organization = current_user.current_organization
  end

  def set_example_model
    @example_model = policy_scope(ExampleModel).find(params[:id])
  end

  def example_model_params
    params.require(:example_model).permit(:name, :status, :description)
  end
end
