require 'rubygems'
require 'mongo'

require File.join(File.dirname(__FILE__), '..', "logging")
require File.join(File.dirname(__FILE__), '..', "settings")

module GHTorrent
  class MongoPersister
    include GHTorrent::Settings
    include GHTorrent::Logging

    LOCALCONFIG = {
        :mongo_host => "mongo.host",
        :mongo_port => "mongo.port",
        :mongo_db => "mongo.db",
        :mongo_username => "mongo.username",
        :mongo_passwd => "mongo.password",
        :mongo_commits => "mongo.commits",
        :mongo_events => "mongo.events",
        :mongo_users => "mongo.users",
        :mongo_repos => "mongo.repos"
    }

    CONFIGKEYS.merge LOCALCONFIG

    def initialize
      @mongo = Mongo::Connection.new(config(:mongo_host),
                                     config(:mongo_port))\
                                .db(config(:mongo_db))
      @enttodb = {
          :users => users_col,
          :commits => commits_col,
          :repos => repos_col,
          :follows => "follows"
      }
    end

    def commits_col
      @mongo.collection(config(:mongo_commits))
    end

    def users_col
      @mongo.collection(config(:mongo_users))
    end

    def repos_col
      @mongo.collection(config(:mongo_repos))
    end


    def store(entity, data = {})

      col = @enttodb[entity]

      if col.nil?
        raise GHTorrentException("Entity #{entity} not supported yet")
      end

      col.insert(data)

    end

    def retrieve(entity, query = {})

      col = @enttodb[entity]

      if col.nil?
        raise GHTorrentException("Entity #{entity} not supported yet")
      end

      result = col.find(query)
      result.to_a
    end

  end
end