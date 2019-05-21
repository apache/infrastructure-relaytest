from buildbot.status.base import StatusReceiverMultiService
from buildbot.status.builder import Results, SUCCESS
import os
import requests
import json


class SlackStatusPush(StatusReceiverMultiService):
    """
    Sends messages to a Slack.io channel when each build finishes with a handy
    link to the build results.
    """

    def __init__(self, weburl,
                 localhost_replace=False, username=None,
                 icon=None, notify_on_success=True, notify_on_failure=True,
                 **kwargs):
        """
        Creates a SlackStatusPush status service.

        :param weburl: Your Slack weburl
        :param localhost_replace: If your Buildbot web fronted doesn't know
            its public address it will use "localhost" in its links. You can
            change this by setting this variable to true.
        :param username: The user name of the "user" positing the messages on
            Slack.
        :param icon: The icon of the "user" posting the messages on Slack.
        :param notify_on_success: Set this to False if you don't want
            messages when a build was successful.
        :param notify_on_failure: Set this to False if you don't want
            messages when a build failed.
        """

        StatusReceiverMultiService.__init__(self)

        self.weburl = weburl
        self.localhost_replace = localhost_replace
        self.username = username
        self.icon = icon
        self.notify_on_success = notify_on_success
        self.notify_on_failure = notify_on_failure
        self.watched = []

    def setServiceParent(self, parent):
        StatusReceiverMultiService.setServiceParent(self, parent)
        self.master_status = self.parent
        self.master_status.subscribe(self)
        self.master = self.master_status.master

    def disownServiceParent(self):
        self.master_status.unsubscribe(self)
        self.master_status = None
        for w in self.watched:
            w.unsubscribe(self)
        return StatusReceiverMultiService.disownServiceParent(self)

    def builderAdded(self, name, builder):
        self.watched.append(builder)
        return self  # subscribe to this builder

    def buildFinished(self, builder_name, build, result):
        if not self.notify_on_success and result == SUCCESS:
            return

        if not self.notify_on_failure and result != SUCCESS:
            return

        build_url = self.master_status.getURLForThing(build)
        if self.localhost_replace:
            build_url = build_url.replace("//localhost", "//{}".format(
                self.localhost_replace))

        source_stamps = build.getSourceStamps()
        branch_names = ', '.join([source_stamp.branch for source_stamp in source_stamps])
        repositories = ', '.join([source_stamp.repository for source_stamp in source_stamps])
        responsible_users = ', '.join(build.getResponsibleUsers())
        revision = ', '.join([source_stamp.revision for source_stamp in source_stamps])
        project = ', '.join([source_stamp.project for source_stamp in source_stamps])

        if result == SUCCESS:
            status = "Success"
            color = "good"
        else:
            status = "Failure"
            color = "failure"

        message = "New Build for {project} ({revision})\nStatus: *{status}*\nBuild details: {url}".format(
            project=project,
            revision=revision,
            status=status,
            url=build_url
        )

        fields = []
        if responsible_users:
            fields.append({
                "title": "Commiters",
                "value": responsible_users
            })

        if repositories:
            fields.append({
                "title": "Repository",
                "value": repositories,
                "short": True
            })

        if branch_names:
            fields.append({
                "title": "Branch",
                "value": branch_names,
                "short": True
            })

        payload = {
            "text": " ",
            "attachments": [
              {
                "fallback": message,
                "text": message,
                "color": color,
                "mrkdwn_in": ["text", "title", "fallback"],
                "fields": fields
              }
            ]
        }

        if self.username:
            payload['username'] = self.username

        if self.icon:
            if self.icon.startswith(':'):
                payload['icon_emoji'] = self.icon
            else:
                payload['icon_url'] = self.icon

        if builder_name == 'infrastructure-puppet-deployment':
            requests.post(self.weburl, data=json.dumps(payload))
