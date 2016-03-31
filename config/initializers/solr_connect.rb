SolrConnectConfig.setup do |config|
  tagUrl = ENV['DESMM_TAG_URL']
  config.set("tagUrl", tagUrl)

  solrUrl = ENV['DESMM_SOLR_URL']
  config.set("solrUrl", solrUrl)

  exported_manifests_path = ENV['DESMM_MANIFESTS_PATH']

end
