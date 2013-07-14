class ProfilePresenter
  def initialize(profile)
    @profile = profile
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      @profile.to_json
    when "full"
      DB.select_value(full)
    when "observations"
      DB.select_value(observations)
    else
      DB.select_value(summary)
    end
  end

  def explain(query)
    DB.execute("explain analyze "+query)
  end

  def summary
    <<-SQL
      select row_to_json(t)
      from (
        select profiles.id, observations_count, simulator_instance_id, (
          select array_to_json(array_agg(symmetry_group))
          from (
            select symmetry_groups.id, role, strategy, count,
            avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd
            from symmetry_groups, players
            where players.symmetry_group_id = symmetry_groups.id
            and symmetry_groups.profile_id = profiles.id
            group by symmetry_groups.id
            order by symmetry_groups.id
          ) symmetry_group
        ) as symmetry_groups
        from profiles
        where profiles.id = #{@profile.id}
      ) t
    SQL
  end

  def observations
    <<-SQL
      select row_to_json(t)
      from (
        select profiles.id, simulator_instance_id, (
          select array_to_json(array_agg(symmetry_group))
          from (
            select symmetry_groups.id, role, strategy, count
            from symmetry_groups
            where profile_id = profiles.id
            order by symmetry_groups.id
          ) symmetry_group
        ) as symmetry_groups,
        (
          select array_to_json(array_agg(observation))
          from (
            select features, (
              select array_to_json(array_agg(sg))
              from (
                select symmetry_group_id as id, avg(payoff) as payoff,
                  stddev_samp(payoff) as payoff_sd
                from players
                where observation_id = observations.id
                group by symmetry_group_id order by symmetry_group_id
              ) sg
            ) as symmetry_groups
            from observations
            where profile_id = profiles.id
          ) observation
        ) as observations
        from profiles
        where profiles.id = #{@profile.id}
      ) t
    SQL
  end

  def full
    <<-SQL
      select row_to_json(t)
      from (
        select profiles.id, simulator_instance_id, (
          select array_to_json(array_agg(symmetry_group))
          from (
            select symmetry_groups.id, role, strategy, count
            from symmetry_groups
            where profile_id = profiles.id
          ) symmetry_group
        ) as symmetry_groups,
        (
          select array_to_json(array_agg(observation))
          from (
            select features, (
              select array_to_json(array_agg(player))
              from (
                select symmetry_group_id, payoff, features
                from players
                where observation_id = observations.id
              ) player
            ) as players
            from observations
            where profile_id = profiles.id
          ) observation
        ) as observations
        from profiles
        where profiles.id = #{@profile.id}
      ) t
    SQL
  end
end