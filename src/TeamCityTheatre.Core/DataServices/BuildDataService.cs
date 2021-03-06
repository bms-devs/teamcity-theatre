﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using RestSharp;
using TeamCityTheatre.Core.Client;
using TeamCityTheatre.Core.Client.Mappers;
using TeamCityTheatre.Core.Client.Responses;
using TeamCityTheatre.Core.Models;
using TeamCityTheatre.Core.Options;

namespace TeamCityTheatre.Core.DataServices {
  public interface IBuildDataService {
    Task<IEnumerable<IDetailedBuild>> GetBuildsOfBuildConfigurationAsync(string buildConfigurationId, int count = 100);
    Task<IDetailedBuild> GetBuildDetailsAsync(int buildId);
  }

  public class BuildDataService : IBuildDataService {
    readonly ITeamCityClient _teamCityClient;
    readonly IBuildMapper _buildMapper;
    readonly ApiOptions _apiOptions;

    public BuildDataService(ITeamCityClient teamCityClient, IBuildMapper buildMapper, IOptions<ApiOptions> apiOptions) {
      _teamCityClient = teamCityClient ?? throw new ArgumentNullException(nameof(teamCityClient));
      _buildMapper = buildMapper ?? throw new ArgumentNullException(nameof(buildMapper));
      _apiOptions = apiOptions?.Value ?? throw new ArgumentNullException(nameof(apiOptions));
    }

    public async Task<IEnumerable<IDetailedBuild>> GetBuildsOfBuildConfigurationAsync(string buildConfigurationId, int count = 100) {
      var request = new RestRequest(_apiOptions.GetBuildsOfBuildConfiguration);
      request.AddUrlSegment("count", Convert.ToString(count));
      request.AddUrlSegment("buildConfigurationId", buildConfigurationId);
      var response = await _teamCityClient.ExecuteRequestAsync<BuildsResponse>(request);
      return _buildMapper.Map(response);
    }

    public async Task<IDetailedBuild> GetBuildDetailsAsync(int buildId) {
      var request = new RestRequest("builds/id:{buildId}");
      request.AddUrlSegment("buildId", Convert.ToString(buildId));
      var response = await _teamCityClient.ExecuteRequestAsync<BuildResponse>(request);
      return _buildMapper.Map(response);
    }
  }
}