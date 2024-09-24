from page_tracker.app import app
import unittest.mock
from redis import ConnectionError


@unittest.mock.patch("page_tracker.app.redis")
def test_should_call_redis_incr(mock_redis, http_client):
    '''
        Test function. Thakes two arguments:
          mock_redis (created by patch)  
          http_client (test_fixture function created)
    '''
    # Given
    #Configure mocked redis to always return 5
    mock_redis.return_value.incr.return_value = 5

    # When
    response = http_client.get("/")

    # Then
    assert response.status_code == 200
    assert response.text == "This page has been seen 5 times."
    mock_redis.return_value.incr.assert_called_once_with("page_views")


@unittest.mock.patch("page_tracker.app.redis")
def test_should_handle_redis_connection_error(mock_redis, http_client):
    # Given
    # Configures the mock Redis object's incr method to raise a ConnectionError when called
    mock_redis.return_value.incr.side_effect = ConnectionError

    # When
    response = http_client.get("/")

    # Then
    assert response.status_code == 500
    assert response.text == "Sorry, something went wrong \N{pensive face}"