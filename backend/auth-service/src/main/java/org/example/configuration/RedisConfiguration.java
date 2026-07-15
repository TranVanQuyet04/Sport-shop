package org.example.configuration;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.jedis.JedisConnectionFactory;
import org.springframework.util.StringUtils;

@Slf4j
@Configuration
public class RedisConfiguration {
    @Value("${spring.data.redis.host}")
    private String host;

    @Value("${spring.data.redis.port}")
    private int port;

    @PostConstruct
    public void validateConfiguration(){
        if (!StringUtils.hasText(host)){
            throw new IllegalStateException("Redis host is not configured");
        }

        if (port <= 0 || port >= 65535){
            throw new IllegalStateException(
                    String.format("Invalid redis port: %d. Port must be between 1 and 65535", port)
            );
        }
        log.info("Redis configuration validated - Host: {}, Port {}", host, port);
    }

    @Bean
    public JedisConnectionFactory redisConnectionFactory() {
        RedisStandaloneConfiguration redisConfig = new RedisStandaloneConfiguration(host,port);
        JedisConnectionFactory factory = new JedisConnectionFactory(redisConfig);
        log.info("Redis connection factory created successfully");

        return factory;
    }
}

