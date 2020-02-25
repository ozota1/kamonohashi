# coding: utf-8

"""
    KAMONOHASHI API

    A platform for deep learning  # noqa: E501

    OpenAPI spec version: v1
    Contact: kamonohashi-support@jp.nssol.nipponsteel.com
    Generated by: https://github.com/swagger-api/swagger-codegen.git
"""


import pprint
import re  # noqa: F401

import six


class AccountApiModelsAccountOutputModel(object):
    """NOTE: This class is auto generated by the swagger code generator program.

    Do not edit the class manually.
    """

    """
    Attributes:
      swagger_types (dict): The key is attribute name
                            and the value is attribute type.
      attribute_map (dict): The key is attribute name
                            and the value is json key in definition.
    """
    swagger_types = {
        'default_tenant': 'InfosTenantInfo',
        'password_change_enabled': 'bool',
        'selected_tenant': 'InfosTenantInfo',
        'tenants': 'list[InfosTenantInfo]',
        'user_id': 'int',
        'user_name': 'str'
    }

    attribute_map = {
        'default_tenant': 'defaultTenant',
        'password_change_enabled': 'passwordChangeEnabled',
        'selected_tenant': 'selectedTenant',
        'tenants': 'tenants',
        'user_id': 'userId',
        'user_name': 'userName'
    }

    def __init__(self, default_tenant=None, password_change_enabled=None, selected_tenant=None, tenants=None, user_id=None, user_name=None):  # noqa: E501
        """AccountApiModelsAccountOutputModel - a model defined in Swagger"""  # noqa: E501

        self._default_tenant = None
        self._password_change_enabled = None
        self._selected_tenant = None
        self._tenants = None
        self._user_id = None
        self._user_name = None
        self.discriminator = None

        if default_tenant is not None:
            self.default_tenant = default_tenant
        if password_change_enabled is not None:
            self.password_change_enabled = password_change_enabled
        if selected_tenant is not None:
            self.selected_tenant = selected_tenant
        if tenants is not None:
            self.tenants = tenants
        if user_id is not None:
            self.user_id = user_id
        if user_name is not None:
            self.user_name = user_name

    @property
    def default_tenant(self):
        """Gets the default_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The default_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: InfosTenantInfo
        """
        return self._default_tenant

    @default_tenant.setter
    def default_tenant(self, default_tenant):
        """Sets the default_tenant of this AccountApiModelsAccountOutputModel.


        :param default_tenant: The default_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: InfosTenantInfo
        """

        self._default_tenant = default_tenant

    @property
    def password_change_enabled(self):
        """Gets the password_change_enabled of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The password_change_enabled of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: bool
        """
        return self._password_change_enabled

    @password_change_enabled.setter
    def password_change_enabled(self, password_change_enabled):
        """Sets the password_change_enabled of this AccountApiModelsAccountOutputModel.


        :param password_change_enabled: The password_change_enabled of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: bool
        """

        self._password_change_enabled = password_change_enabled

    @property
    def selected_tenant(self):
        """Gets the selected_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The selected_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: InfosTenantInfo
        """
        return self._selected_tenant

    @selected_tenant.setter
    def selected_tenant(self, selected_tenant):
        """Sets the selected_tenant of this AccountApiModelsAccountOutputModel.


        :param selected_tenant: The selected_tenant of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: InfosTenantInfo
        """

        self._selected_tenant = selected_tenant

    @property
    def tenants(self):
        """Gets the tenants of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The tenants of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: list[InfosTenantInfo]
        """
        return self._tenants

    @tenants.setter
    def tenants(self, tenants):
        """Sets the tenants of this AccountApiModelsAccountOutputModel.


        :param tenants: The tenants of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: list[InfosTenantInfo]
        """

        self._tenants = tenants

    @property
    def user_id(self):
        """Gets the user_id of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The user_id of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: int
        """
        return self._user_id

    @user_id.setter
    def user_id(self, user_id):
        """Sets the user_id of this AccountApiModelsAccountOutputModel.


        :param user_id: The user_id of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: int
        """

        self._user_id = user_id

    @property
    def user_name(self):
        """Gets the user_name of this AccountApiModelsAccountOutputModel.  # noqa: E501


        :return: The user_name of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :rtype: str
        """
        return self._user_name

    @user_name.setter
    def user_name(self, user_name):
        """Sets the user_name of this AccountApiModelsAccountOutputModel.


        :param user_name: The user_name of this AccountApiModelsAccountOutputModel.  # noqa: E501
        :type: str
        """

        self._user_name = user_name

    def to_dict(self):
        """Returns the model properties as a dict"""
        result = {}

        for attr, _ in six.iteritems(self.swagger_types):
            value = getattr(self, attr)
            if isinstance(value, list):
                result[attr] = list(map(
                    lambda x: x.to_dict() if hasattr(x, "to_dict") else x,
                    value
                ))
            elif hasattr(value, "to_dict"):
                result[attr] = value.to_dict()
            elif isinstance(value, dict):
                result[attr] = dict(map(
                    lambda item: (item[0], item[1].to_dict())
                    if hasattr(item[1], "to_dict") else item,
                    value.items()
                ))
            else:
                result[attr] = value
        if issubclass(AccountApiModelsAccountOutputModel, dict):
            for key, value in self.items():
                result[key] = value

        return result

    def to_str(self):
        """Returns the string representation of the model"""
        return pprint.pformat(self.to_dict())

    def __repr__(self):
        """For `print` and `pprint`"""
        return self.to_str()

    def __eq__(self, other):
        """Returns true if both objects are equal"""
        if not isinstance(other, AccountApiModelsAccountOutputModel):
            return False

        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """Returns true if both objects are not equal"""
        return not self == other
