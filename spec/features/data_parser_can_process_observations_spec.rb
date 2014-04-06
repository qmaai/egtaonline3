require 'spec_helper'

describe "DataParser can process observations" do
  context "when all of the observations are valid" do
    let!(:profile) { FactoryGirl.create(:profile, assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2') }
    let!(:simulation){ FactoryGirl.create(:simulation, profile: profile, state: 'running') }

    it "creates all the required objects" do
      DataParser.new.perform(simulation.id, "#{Rails.root}/spec/support/data/3")
      observations = Observation.all
      observations.count.should == 2
      first_observation, second_observation = observations.to_a
      first_observation.profile_id.should == profile.id
      first_observation.features.should == { "featureA" => "34" }
      first_observation.extended_features.should == { "featureB" => [37, 38],
        "featureC" => { "subfeature1" => 40, "subfeature2" => 42 } }
  		first_symmetry_group = profile.symmetry_groups.find_by(
      	role: 'Buyer', strategy: 'BidValue')
      second_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade1')
      third_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade2')
			first_symmetry_group.payoff.should ==
			  (2992.73+2990.53+2990.73+2690.53)/4.0
			second_symmetry_group.payoff.should ==
			  (2979.34+2929.34)/2.0
			third_symmetry_group.payoff.should ==
			  (2924.44+2824.44)/2.0
			ControlVariable.count.should == 2
			ControlVariable.where(simulator_instance_id: profile.simulator_instance_id, name: "featureA").first.coefficient.should == 0
		  ControlVariable.where(simulator_instance_id: profile.simulator_instance_id, name: "featureC").first.coefficient.should == 0
		  PlayerControlVariable.count.should == 2
			PlayerControlVariable.where(simulator_instance_id: profile.simulator_instance_id, name: "featureA").first.coefficient.should == 0
		  PlayerControlVariable.where(simulator_instance_id: profile.simulator_instance_id, name: "featureC").first.coefficient.should == 0
    end
  end
end