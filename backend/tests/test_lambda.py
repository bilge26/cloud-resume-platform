import json
import os
import sys
import unittest
from unittest.mock import MagicMock, patch

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

import lambda_function


class TestLambdaFunction(unittest.TestCase):

    @patch("lambda_function.get_table")
    def test_lambda_handler_increments_visitor_count(self, mock_get_table):
        mock_table = MagicMock()

        mock_table.update_item.return_value = {
            "Attributes": {
                "count": 42
            }
        }

        mock_get_table.return_value = mock_table

        response = lambda_function.lambda_handler({}, None)

        self.assertEqual(response["statusCode"], 200)

        body = json.loads(response["body"])

        self.assertEqual(body["count"], 42)

        mock_table.update_item.assert_called_once()


if __name__ == "__main__":
    unittest.main()