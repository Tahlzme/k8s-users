data "aws_iam_policy_document" "developer" {
  statement {
    sid    = "AllowDeveloper"
    effect = "Allow"
    actions = [ #below are the developer permissions they need for eks to be able to do anything with the cluster
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:AccessKubernetesApi",
      "ssm:GetParameter",
      "eks:ListUpdates",
      "eks:ListFargateProfiles"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "masters" {
  statement {
    sid       = "AllowAdmin"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole" #the user will need this statement in the policy so that they can pass a role to eks.  this must be specified
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "masters_assume_role" {
  statement {
    sid    = "AllowAccountAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
      #identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/manager"] #here the manager is the principle who can asssume the role. if another user/group need to assume the role then the need to added like below. IAM policy doesnt allow you to put arn for a group here as an assume role or as a principle 
      #identifiers = ["data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "masters_role" {
  statement {
    sid    = "AllowMastersAssumeRole"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Masters-eks-Role"] #principle here is changed to resouces becase you cannot specify principle for a group, but can specify a resource. This is just like any other statement that has, effect, actions and resources like above. the resouce is stating the role that needs to be performmed on
    }
  }


data "aws_caller_identity" "current" {}

#manager access and seceret key
#AKIASW4OZKYZSBJDS7EM
#GzMT+zEqNiK0dkkDy8pNsM8wFtf7wGlNeYxooR1O