module PlinkAdmin
  class ContestQueryService < Warehouse
    self.table_name = 'ft_contest_entries'

    def self.get_statistics(contest_id)
      {
        entries:
          connection.select_all(entries_with_sources(contest_id)),
        emails_and_linked_cards:
          connection.select_all(email_captures_and_linked_cards(contest_id))
      }
    end

  private

    def self.entries_with_sources(contest_id)
      "SELECT
        s.entry_source,
        ISNULL( SUM( s.admin_users ), 0 )         AS admin_users,
        ISNULL( SUM( s.admin_posts ), 0 )         AS admin_posts,
        ISNULL( SUM( s.admin_entries ), 0 )       AS admin_entries,
        ISNULL( SUM( s.facebook_users ),0 )       AS facebook_users,
        ISNULL( SUM( s.facebook_posts ),0 )       AS facebook_posts,
        ISNULL( SUM( s.facebook_entries ),0 )     AS facebook_entries,
        ISNULL( SUM( s.twitter_users ), 0 )       AS twitter_users,
        ISNULL( SUM( s.twitter_posts ), 0 )       AS twitter_posts,
        ISNULL( SUM( s.twitter_entries ), 0 )     AS twitter_entries,
        ISNULL( SUM( s.total_users ), 0 )         AS total_users,
        ISNULL( SUM( s.total_posts ), 0 )         AS total_posts,
        ISNULL( SUM( s.total_entries ), 0 )       AS total_entries
      FROM
      (
        SELECT
          entry_source,
          CASE WHEN provider = 'admin'  THEN COUNT( DISTINCT user_id )  END AS admin_users,
          CASE WHEN provider = 'admin'  THEN SUM( computed_entries )  END AS admin_entries,
          CASE WHEN provider = 'admin'  THEN COUNT( 1 )         END AS admin_posts,
          CASE WHEN provider = 'facebook' THEN COUNT( DISTINCT user_id )  END AS facebook_users,
          CASE WHEN provider = 'facebook' THEN SUM( computed_entries )  END AS facebook_entries,
          CASE WHEN provider = 'facebook' THEN COUNT( 1 )         END AS facebook_posts,
          CASE WHEN provider = 'twitter'  THEN COUNT( DISTINCT user_id )  END AS twitter_users,
          CASE WHEN provider = 'twitter'  THEN SUM( computed_entries )  END AS twitter_entries,
          CASE WHEN provider = 'twitter'  THEN COUNT( 1 )         END AS twitter_posts,
          0                                 AS total_users,
          0                                 AS total_entries,
          0                                 AS total_posts
        FROM    ft_contest_entries
        WHERE   contest_id = #{contest_id}
        GROUP BY  entry_source,
              provider

        UNION

        SELECT
          entry_source,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          COUNT( DISTINCT user_id )                     AS total_users,
          SUM( computed_entries )                       AS total_entries,
          COUNT( 1 )                              AS total_posts
        FROM    ft_contest_entries
        WHERE   contest_id = #{contest_id}
        GROUP BY  entry_source

      ) s
      GROUP BY  s.entry_source

      UNION

      SELECT
            'Grand Total' AS entry_source,
            ISNULL( SUM( s2.admin_users ), 0 )    AS admin_users,
            ISNULL( SUM( s2.admin_posts ), 0 )    AS admin_posts,
            ISNULL( SUM( s2.admin_entries ), 0 )  AS admin_entries,
            ISNULL( SUM( s2.facebook_users ),0 )  AS facebook_users,
            ISNULL( SUM( s2.facebook_posts ),0 )  AS facebook_posts,
            ISNULL( SUM( s2.facebook_entries ),0 )  AS facebook_entries,
            ISNULL( SUM( s2.twitter_users ), 0 )  AS twitter_users,
            ISNULL( SUM( s2.twitter_posts ), 0 )  AS twitter_posts,
            ISNULL( SUM( s2.twitter_entries ), 0 )  AS twitter_entries,
            ISNULL( SUM( s2.total_users ), 0 )    AS total_users,
            ISNULL( SUM( s2.total_posts ), 0 )    AS total_posts,
            ISNULL( SUM( s2.total_entries ), 0 )  AS total_entries
      FROM
      (
        SELECT
          CASE WHEN provider = 'admin'    THEN COUNT( DISTINCT user_id )  END AS admin_users,
          CASE WHEN provider = 'admin'    THEN SUM( computed_entries )  END AS admin_entries,
          CASE WHEN provider = 'admin'    THEN COUNT( 1 ) END AS admin_posts,
          CASE WHEN provider = 'facebook' THEN COUNT( DISTINCT user_id )  END AS facebook_users,
          CASE WHEN provider = 'facebook' THEN SUM( computed_entries )  END AS facebook_entries,
          CASE WHEN provider = 'facebook' THEN COUNT( 1 ) END AS facebook_posts,
          CASE WHEN provider = 'twitter'  THEN COUNT( DISTINCT user_id )  END AS twitter_users,
          CASE WHEN provider = 'twitter'  THEN SUM( computed_entries )  END AS twitter_entries,
          CASE WHEN provider = 'twitter'  THEN COUNT( 1 ) END AS twitter_posts,
          0                               AS total_users,
          0                               AS total_entries,
          0                               AS total_posts
        FROM    ft_contest_entries
        WHERE   contest_id = #{contest_id}
        GROUP BY  provider

        UNION

        SELECT
          0                                 AS admin_users,
          0                                 AS admin_entries,
          0                                 AS admin_posts,
          0                                 AS facebook_users,
          0                                 AS facebook_entries,
          0                                 AS facebook_posts,
          0                                 AS twitter_users,
          0                                 AS twitter_entries,
          0                                 AS twitter_posts,
          COUNT( DISTINCT user_id )                     AS total_users,
          SUM( computed_entries )                       AS total_entries,
          COUNT( 1 )                              AS total_posts
        FROM    ft_contest_entries
        WHERE   contest_id = #{contest_id}
      ) s2
      GROUP BY  1
      ORDER BY  total_entries
      ;"
    end

    def self.email_captures_and_linked_cards(contest_id)
      "SELECT r.sub_id_1 AS registration_source,
              COUNT( r.user_id ) AS email_captures,
              COUNT( DISTINCT l.user_id ) AS linked_cards
      FROM
      (
        SELECT  r.user_id,
            r.sub_id_1
        FROM  ft_registrations r
        WHERE r.affiliate_id = 1431
        AND   r.join_rank = 1
        AND   r.sub_id_2 = 'contest_id_#{contest_id}'
      ) r
      LEFT JOIN
      (
        SELECT  DISTINCT l.user_id
        FROM  ft_linked_cards l
        WHERE l.link_rank = 1
        AND   l.sub_id_2 = 'contest_id_#{contest_id}'
      ) l
      ON r.user_id = l.user_id
      GROUP BY  r.sub_id_1

      UNION

      SELECT  'other' AS registration_source,
          NULL  AS email_captures,
          COUNT( l.user_id ) AS linked_cards
      FROM
      (
        SELECT  u.user_id
        FROM  dm_users u
        WHERE u.join_affiliate <> 1431
      ) u
      LEFT JOIN
      (
        SELECT  DISTINCT l.user_id
        FROM  ft_linked_cards l
        WHERE l.sub_id_2 = 'contest_id_#{contest_id}'
        AND   l.link_rank = 1
      ) l
      ON u.user_id = l.user_id

      UNION

      SELECT  'grand_total' AS registration_source,
          r.email_captures AS email_captures,
          l.linked_cards AS linked_cards
      FROM(
        SELECT  COUNT( DISTINCT r.user_id ) AS email_captures
        FROM  ft_registrations r
        WHERE   r.affiliate_id = 1431
        AND   r.sub_id_2 = 'contest_id_#{contest_id}'
        AND   r.join_rank = 1
      ) r,
      (
        SELECT  COUNT( DISTINCT l.user_id ) AS linked_cards
        FROM  ft_linked_cards l
        WHERE l.sub_id_2 = 'contest_id_#{contest_id}'
        AND   l.link_rank = 1
      ) l
      ORDER BY 3;"
    end
  end
end
