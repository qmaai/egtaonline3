class AnalysesController < AuthenticatedController
  expose(:analyses) do
    Analysis.order("#{sort_column} #{sort_direction}")
      .page(params[:page])
  end
  expose(:analysis)

  def show
    respond_to do |format|
      format.html do
      end

      format.json do
        file_name = AnalysisPresenter.new(analysis).get_output(output: params[:output])
        send_file file_name, type: 'text'
      end
    end
  end


  private

  def default_order
    'id'
  end
end
