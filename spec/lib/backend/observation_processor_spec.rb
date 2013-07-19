require 'backend/observation_processor'

describe ObservationProcessor do
  describe 'process_files' do
    let(:symmetry_groups){ double('Criteria') }
    let(:profile){ double(id: 1, symmetry_groups: symmetry_groups) }
    let(:simulation){ double(profile: profile) }
    let(:valid_path){ 'some/path.json' }
    let(:invalid_path){ 'some/other/path.json' }

    context 'when some of the files are valid' do
      let(:files){ [invalid_path, valid_path] }
      let(:data){
        {
          "features" => {
            "featureA" => 34.0,
            "featureB" => [37, 38],
            "featureC" => {
              "C1" => 40.0, "C2" => 42.0
            }
          },
          "symmetry_groups" => [
            {
              "role" => 'Role1',
              "strategy" => 'Strategy1',
              "players" => [
                {
                  "payoff" => 2992.73,
        			    "features" => {
        				    "featureA" => 0.001,
        				    "featureB" => [2.0, 2.1]
        			    }
        			  }
              ]
            },
            {
              "role" => 'Role2',
              "strategy" => 'Strategy2',
              "players" => [
                {
                  "payoff" => 2929.34
                },
                {
        				  "payoff" => 2000.00
        			  }
              ]
            }
          ]
        }
      }
      let(:observations){ double('Other Criteria') }
      let(:obs){ double(valid?: true) }
      let(:players){ double('Player Criteria') }

      before do
        ObservationValidator.should_receive(:validate).with(profile,
          invalid_path).and_return(nil)
        ObservationValidator.should_receive(:validate).with(profile,
          valid_path).and_return(data)
      end

      it 'creates the records for the data and completes the simulation' do
       profile.should_receive(:add_observation).with(data)
        simulation.should_receive(:finish)
      end
    end

    context 'when there are no valid files' do
      let(:files){ [invalid_path, invalid_path] }
      before do
        ObservationValidator.should_receive(:validate).with(profile,
          invalid_path).twice.and_return(nil)
      end

      it 'fails the simulation' do
        simulation.should_receive(:fail).with(
          "No valid observations were found.")
      end
    end

    after do
      ObservationProcessor.process_files(simulation, files)
    end
  end
end